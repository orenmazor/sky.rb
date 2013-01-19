require 'skydb/query/selection_parse_error'
require 'skydb/query/selection_field'
require 'skydb/query/ast'
require 'skydb/query/selection_grammar'

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
      def self.parse(str)
        # Parse the selection string.
        parser = SelectionGrammarParser.new()
        ast = parser.parse(str)

        # If there was a problem then throw a parse error.
        if ast.nil?
          raise SkyDB::Query::SelectionParseError.new(parser.failure_reason,
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
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # A list of fields that will be returned from the server.
      attr_accessor :fields


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
          body << "data.#{field.expression} = data.#{field.expression}"
        end
        
        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end
    end
  end
end