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
    
      # Executes the query and returns the resulting data.
      def results
        # TODO: Build Lua query and execute it on the server.
        # TODO: Return the results.
      end
    end
  end
end