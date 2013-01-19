class SkyDB
  class Query
    class Ast
      module SelectionFieldSyntaxNode
        # Generates the SelectionField object from the node.
        def generate
          field = SkyDB::Query::SelectionField.new(
            :expression => (respond_to?('expression') ? expression.text_value : text_value)
          )
          field.alias_name = alias_name.text_value if respond_to?('alias_name')
          field.aggregation_type = aggregation_type.text_value.downcase.to_sym if respond_to?('aggregation_type')
          return field
        end
      end
    end
  end
end
