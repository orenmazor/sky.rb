class SkyDB
  # The selection field is a single field in the selection part of the query.
  # This can include a simple property or it can be the aggregation of a
  # property. Fields can also be aliased to a different name that is returned.
  # This is typically useful when naming aggregated fields.
  class Query
    class SelectionField
      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      def initialize(options={})
        self.expression = options[:expression]
        self.alias_name = options[:alias_name]
        self.aggregation_type = options[:aggregation_type]
        self.data_type = options[:data_type]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The name of the property to select.
      attr_accessor :expression

      # The field name that is actually returned.
      attr_accessor :alias_name

      # The type of the aggregation used to process the property.
      attr_accessor :aggregation_type

      # The data type of the expression. This is especially important when
      # accessing string data since it needs to be handled differently in Sky.
      attr_accessor :data_type
    end
  end
end