class SkyDB
  class Query
    class Ast
      module SelectionFieldSyntaxNode
        # Generates the SelectionField object from the node.
        def generate
          field = SkyDB::Query::SelectionField.new(
            :expression => text_value
          )
          return field
        end
      end
    end
  end
end
