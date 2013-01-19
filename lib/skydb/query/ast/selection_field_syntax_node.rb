class SkyDB
  class Query
    class Ast
      module SelectionFieldSyntaxNode
        # Generates the SelectionField object from the node.
        def generate
          if !respond_to?('expression')
            return SkyDB::Query::SelectionField.new(
              :expression => text_value
            )

          elsif respond_to?('alias_name')
            return SkyDB::Query::SelectionField.new(
              :expression => expression.text_value,
              :alias_name => alias_name.text_value
            )
          end
        end
      end
    end
  end
end
