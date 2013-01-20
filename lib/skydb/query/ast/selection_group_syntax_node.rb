class SkyDB
  class Query
    class Ast
      module SelectionGroupSyntaxNode
        # Generates the SelectionGroup object from the node.
        def generate
          group = SkyDB::Query::SelectionGroup.new(
            :expression => (respond_to?('expression') ? expression.text_value : text_value)
          )
          group.alias_name = alias_name.text_value if respond_to?('alias_name')
          return group
        end
      end
    end
  end
end
