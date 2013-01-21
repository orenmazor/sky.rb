class SkyDB
  # The selection group contains an expression by which to group selected
  # data.
  class Query
    class SelectionGroup
      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      def initialize(options={})
        self.expression = options[:expression]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The name of the expression to group by.
      attr_accessor :expression
    end
  end
end