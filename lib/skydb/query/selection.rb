require 'skydb/query/selection_fields_parse_error'
require 'skydb/query/selection_field'

require 'skydb/query/selection_groups_parse_error'
require 'skydb/query/selection_group'

require 'skydb/query/ast/selection_fields_syntax_node'
require 'skydb/query/ast/selection_field_syntax_node'
require 'skydb/query/ast/selection_groups_syntax_node'
require 'skydb/query/ast/selection_group_syntax_node'
require 'skydb/query/selection_fields_grammar'
require 'skydb/query/selection_groups_grammar'

class SkyDB
  class Query
    # The selection object contains a list of all fields and their aliases.
    # Selection fields can include simple properties as well as aggregation
    # functions.
    class Selection
      ##########################################################################
      #
      # Static Methods
      #
      ##########################################################################

      # Parses a string into a list of selection fields.
      #
      # @param [String] str  A formatted list of fields to select.
      #
      # @return [Array]  An array of selection fields.
      def self.parse_fields(str)
        # Parse the selection fields string.
        parser = SelectionFieldsGrammarParser.new()
        ast = parser.parse(str)

        # If there was a problem then throw a parse error.
        if ast.nil?
          raise SkyDB::Query::SelectionFieldsParseError.new(parser.failure_reason,
            :line => parser.failure_line,
            :column => parser.failure_column
          )
        end
        
        return ast.generate
      end

      # Parses a string into a list of selection groups.
      #
      # @param [String] str  A formatted list of fields to group by.
      #
      # @return [Array]  An array of selection groups.
      def self.parse_groups(str)
        # Parse the selection groups string.
        parser = SelectionGroupsGrammarParser.new()
        ast = parser.parse(str)

        # If there was a problem then throw a parse error.
        if ast.nil?
          raise SkyDB::Query::SelectionGroupsParseError.new(parser.failure_reason,
            :line => parser.failure_line,
            :column => parser.failure_column
          )
        end
        
        return ast.generate
      end
      

      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      def initialize(options={})
        self.query = options[:query]
        self.fields = options[:fields] || []
        self.groups = options[:groups] || []
        self.conditions = options[:conditions] || []
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The query this selection is attached to.
      attr_accessor :query

      # A list of fields that will be returned from the server.
      attr_accessor :fields

      # A list of expressions to group the returned data by.
      attr_accessor :groups

      # A list of conditions that must be fulfilled before performing a
      # selection.
      attr_accessor :conditions


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################
    
      ####################################
      # Helpers
      ####################################

      # Adds a list of fields to the selection.
      #
      # @param [String] args  A list of fields to add to the selection.
      #
      # @return [Selection]  The selection object is returned.
      def select(*args)
        args.each do |arg|
          if arg.is_a?(String)
            self.fields = self.fields.concat(SkyDB::Query::Selection.parse_fields(arg))
          elsif arg.is_a?(Symbol)
            self.fields << SelectionField.new(:expression => arg.to_s)
          else
            raise "Invalid selection argument: #{arg} (#{arg.class})"
          end
        end
        
        return self
      end

      # Adds one or more grouping fields to the selection of the query.
      #
      # @param [String] args  A list of groups to add to the selection.
      #
      # @return [Selection]  The selection object is returned.
      def group_by(*args)
        args.each do |arg|
          if arg.is_a?(String)
            self.groups = self.groups.concat(SkyDB::Query::Selection.parse_groups(arg))
          elsif arg.is_a?(Symbol)
            self.groups << SelectionGroup.new(:expression => arg.to_s)
          else
            raise "Invalid group by argument: #{arg} (#{arg.class})"
          end
        end
        
        return self
      end

      # Adds an 'after' condition to the query.
      #
      # @param [Hash] options  The options to pass to the 'after' condition.
      #
      # @return [Query]  The query object is returned.
      def after(options={})
        conditions << SkyDB::Query::AfterCondition.new(options)
        return self
      end

      # Adds an 'on' condition to the query.
      #
      # @param [Hash] options  The options to pass to the 'on' condition.
      #
      # @return [Query]  The query object is returned.
      def on(options={})
        conditions << SkyDB::Query::OnCondition.new(options)
        return self
      end


      ####################################
      # Validation
      ####################################

      # Validates that all the elements of the query are valid.
      def validate!
        # Require that at least one field exist.
        if fields.length == 0
          raise SkyDB::Query::ValidationError.new("At least one selection field is required for #{self.inspect}.")
        end

        fields.each do |field|
          field.validate!
        end

        groups.each do |group|
          group.validate!
        end
      end


      ####################################
      # Codegen
      ####################################

      # Generates Lua code for the entire selection including conditions and
      # merging.
      def codegen
        return [
          codegen_select(),
          codegen_select_all(),
          codegen_merge()
          ].join("\n")
      end

      # Generates Lua code for the aggregation based on the selection.
      def codegen_select
        header, body, footer = "function select(cursor, data)\n", [], "end\n"
      
        # Setup target object.
        body << "target = data"
        body << "" if groups.length > 0

        # Initialize groups.
        groups.each do |group|
          body << "group_value = #{group.accessor}"
          body << "if cursor:eos() or cursor:eof() then group_value = -1 end" if group.expression == 'action_id'
          body << "if target[group_value] == nil then"
          body << "  target[group_value] = {}"
          body << "end"
          body << "target = target[group_value]"
          body << ""
        end

        # Generate the assignment for each field.
        fields.each do |field|
          alias_name = field.target_name
          
          case field.aggregation_type
          when nil
            body << "target.#{alias_name} = #{field.accessor}"
          when :count
            body << "target.#{alias_name} = (target.#{alias_name} or 0) + 1"
          when :sum
            body << "target.#{alias_name} = (target.#{alias_name} or 0) + #{field.accessor}"
          when :min
            body << "if(target.#{alias_name} == nil or target.#{alias_name} > #{field.accessor}) then"
            body << "  target.#{alias_name} = #{field.accessor}"
            body << "end"
          when :max
            body << "if(target.#{alias_name} == nil or target.#{alias_name} < #{field.accessor}) then"
            body << "  target.#{alias_name} = #{field.accessor}"
            body << "end"
          else
            raise StandardError.new("Invalid aggregation type: #{field.aggregation_type}")
          end
        end
        
        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end

      # Generates Lua code for the aggregation based on the selection.
      def codegen_select_all
        header, body, footer = "function selectAll(cursor, data)\n", [], "end\n"
      
        # Generate the invocation of the conditions.
        conditional_functions = codegen_conditional_functions()
        conditionals = conditions.map {|condition| "#{condition.function_name}(cursor, data)"}.join(' and ')
        conditionals = "true" if conditions.length == 0
        
        body << "while cursor:next_session() do"
        body << "  while cursor:next() do"
        body << "    if #{conditionals} then"
        body << "      select(cursor, data)"
        body << "    end"
        body << "  end"
        body << "end"

        # Indent body and return.
        body.map! {|line| "  " + line}
        return conditional_functions + "\n" + header + body.join("\n") + "\n" + footer
      end

      # Generates Lua code for the conditional functions.
      def codegen_conditional_functions
        code = []
        
        # Generate condition functions.
        conditions.each_with_index do |condition, index|
          condition.function_name ||= "__condition#{query.nextseq}"
          code << condition.codegen
        end

        return code.join("\n")
      end


      # Generates Lua code for the merge function.
      def codegen_merge
        header, body, footer = "function merge(results, data)\n", [], "end\n"

        # Open group loops.
        groups.each_with_index do |group, index|
          data_item = "data" + (0...index).to_a.map {|i| "[k#{i}]"}.join('')
          results_item = "results" + (0..index).to_a.map {|i| "[k#{i}]"}.join('')
          body << "#{'  ' * index}for k#{index},v#{index} in pairs(#{data_item}) do"
          body << "#{'  ' * index}  if #{results_item} == nil then #{results_item} = {} end"
        end

        indent = '  ' * groups.length
        body << "#{indent}a = results" + (0...groups.length).to_a.map {|i| "[k#{i}]"}.join('')
        body << "#{indent}b = data" + (0...groups.length).to_a.map {|i| "[k#{i}]"}.join('')

        # Generate the merge for each field.
        fields.each do |field|
          alias_name = field.target_name
          
          case field.aggregation_type
          when nil
            body << "#{indent}a.#{alias_name} = b.#{alias_name}"
          when :count
            body << "#{indent}a.#{alias_name} = (a.#{alias_name} or 0) + (b.#{alias_name} or 0)"
          when :sum
            body << "#{indent}a.#{alias_name} = (a.#{alias_name} or 0) + (b.#{alias_name} or 0)"
          when :min
            body << "#{indent}if(a.#{alias_name} == nil or a.#{alias_name} > b.#{alias_name}) then"
            body << "#{indent}  a.#{alias_name} = b.#{alias_name}"
            body << "#{indent}end"
          when :max
            body << "#{indent}if(a.#{alias_name} == nil or a.#{alias_name} < b.#{alias_name}) then"
            body << "#{indent}  a.#{alias_name} = b.#{alias_name}"
            body << "#{indent}end"
          else
            raise StandardError.new("Invalid aggregation type: #{field.aggregation_type}")
          end
        end

        # Close group loops.
        groups.reverse.each_with_index do |group, index|
          body << "#{'  ' * (groups.length-index-1)}end"
        end

        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end


      ####################################
      # Serialization
      ####################################
    
      # Serializes the selection object into a JSON string.
      def to_json(*a); to_hash.to_json(*a); end

      # Serializes the selection object into a hash.
      def to_hash(*a)
        {
          'fields' => fields.to_a.map {|f| f.to_hash},
          'groups' => groups.to_a.map {|g| g.to_hash},
          'conditions' => conditions.to_a.map {|c| c.to_hash}
        }
      end
    
      # Deserializes the selection object from a hash.
      def from_hash(hash, *a)
        return nil if hash.nil?
        self.fields = hash['fields'].to_a.map {|h| SkyDB::Query::SelectionField.new.from_hash(h, *a)}
        self.groups = hash['groups'].to_a.map {|h| SkyDB::Query::SelectionGroup.new.from_hash(h, *a)}
        self.conditions = hash['conditions'].to_a.map do |h|
          if h['type'] == 'on'
            SkyDB::Query::OnCondition.new.from_hash(h, *a)
          else
            SkyDB::Query::AfterCondition.new.from_hash(h, *a)
          end
        end
        return self
      end
    
      ####################################
      # Identifier Management
      ####################################

      # Retrieves a list of all action objects.
      def get_identifiers
        actions = []
        
        conditions.each do |condition|
          if condition.action.is_a?(SkyDB::Action) && condition.action.id.to_i == 0
            actions << condition.action
          end
        end
        
        return actions
      end
    end
  end
end

