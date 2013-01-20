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
    
      # Generates Lua code based on the items in the selection.
      def codegen
        header, body, footer = "function select(cursor, data)\n", [], "end\n"
      
        # Generate the assignment for each field.
        fields.each do |field|
          alias_name = !field.alias_name.nil? ? field.alias_name : field.expression
          
          case field.aggregation_type
          when nil
            body << "data.#{alias_name} = data.#{field.expression}"
          when :count
            body << "data.#{alias_name} = (data.#{alias_name} || 0) + 1"
          when :sum
            body << "data.#{alias_name} = (data.#{alias_name} || 0) + cursor.event.#{field.expression}"
          when :min
            body << "if(data.#{alias_name} == nil || data.#{alias_name} > cursor.event.#{field.expression}) then"
            body << "  data.#{alias_name} = cursor.event.#{field.expression}"
            body << "end"
          when :max
            body << "if(data.#{alias_name} == nil || data.#{alias_name} < cursor.event.#{field.expression}) then"
            body << "  data.#{alias_name} = cursor.event.#{field.expression}"
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

