require 'skydb/query/selection_field'
require 'skydb/query/ast'
require 'skydb/query/selection_grammar'

class SkyDB
  # The selection object contains a list of all fields and their aliases.
  # Selection fields can include simple properties as well as aggregation
  # functions.
  class Query
    class Selection
      ##########################################################################
      #
      # Static Methods
      #
      ##########################################################################

      # Parses a string into a list of selection fields.
      def self.parse(str)
        parser = SelectionGrammarParser.new()
        ast = parser.parse(str)
        p ast
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