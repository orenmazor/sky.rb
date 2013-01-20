class SkyDB
  class Query
    class SelectionGroupsParseError < StandardError
      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      def initialize(message, options={})
        super(message)
        @line = options[:line].to_i
        @column = options[:column].to_i
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The line number that the error occurred on.
      attr_reader :line

      # The column number that the error occurred on.
      attr_reader :column
    end
  end
end