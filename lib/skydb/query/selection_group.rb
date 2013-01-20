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
        self.data_type = options[:data_type]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The name of the expression to group by.
      attr_accessor :expression

      # The data type of the expression. This is especially important when
      # accessing string data since it needs to be handled differently in Sky.
      attr_accessor :data_type
    end
  end
end