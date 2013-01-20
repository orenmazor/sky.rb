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
        self.fields = options[:fields] || []
        self.groups = options[:groups] || []
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # A list of fields that will be returned from the server.
      attr_accessor :fields

      # A list of expressions to group the returned data by.
      attr_accessor :groups


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

      # Generates Lua code based on the items in the selection.
      def codegen
        header, body, footer = "function select(cursor, data)\n", [], "end\n"
      
        # Setup target object.
        body << "target = data"
        body << "" if groups.length > 0

        # Initialize groups.
        groups.each do |group|
          body << "if target[cursor.event.#{group.expression}] == nil then"
          body << "  target[cursor.event.#{group.expression}] = {}"
          body << "end"
          body << "target = target[cursor.event.#{group.expression}]"
          body << ""
        end

        # Generate the assignment for each field.
        fields.each do |field|
          alias_name = field.target_name
          
          case field.aggregation_type
          when nil
            body << "target.#{alias_name} = cursor.event.#{field.expression}"
          when :count
            body << "target.#{alias_name} = (target.#{alias_name} or 0) + 1"
          when :sum
            body << "target.#{alias_name} = (target.#{alias_name} or 0) + cursor.event.#{field.expression}"
          when :min
            body << "if(target.#{alias_name} == nil or target.#{alias_name} > cursor.event.#{field.expression}) then"
            body << "  target.#{alias_name} = cursor.event.#{field.expression}"
            body << "end"
          when :max
            body << "if(target.#{alias_name} == nil or target.#{alias_name} < cursor.event.#{field.expression}) then"
            body << "  target.#{alias_name} = cursor.event.#{field.expression}"
            body << "end"
          else
            raise StandardError.new("Invalid aggregation type: #{field.aggregation_type}")
          end
        end
        
        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end
    end
  end
end

