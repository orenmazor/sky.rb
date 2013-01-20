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

      # The final computed name of the field. It is named after the alias name
      # if provided, otherwise defaults to the expression. If neither the
      # expression or alias are provided then the aggregation type is used.
      def target_name
        return alias_name || expression || aggregation_type.to_s
      end


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################

      ####################################
      # Validation
      ####################################

      # Validates that the field is valid.
      def validate!
        # Expression must be present unless this is a COUNT().
        if expression.to_s.length == 0 && aggregation_type != :count
          raise SkyDB::Query::ValidationError.new("Invalid expression for selection field: '#{expression.to_s}'")
        end
      end
    end
  end
end