class SkyDB
  class Query
    class Ast
      module SelectionFieldSyntaxNode
        # Generates the SelectionField object from the node.
        def generate
          field = SkyDB::Query::SelectionField.new()

          # If there is an expression present then use it.
          if respond_to?('expression')
            field.expression = expression.text_value

          # Otherwise we'll typically use the whole value unless there is an
          # aggregation type mentioned. An example of this is: "count()".
          elsif !respond_to?('aggregation_type')
            field.expression = text_value
          end

          field.alias_name = alias_name.text_value if respond_to?('alias_name')
          field.aggregation_type = aggregation_type.text_value.downcase.to_sym if respond_to?('aggregation_type')
          return field
        end
      end
    end
  end
end
