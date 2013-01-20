class SkyDB
  class Query
    class Ast
      module SelectionGroupsSyntaxNode
        # Generates a list of selection groups.
        def generate
          groups = []
          Treetop.search(self, SelectionGroupSyntaxNode).each do |group_node|
            groups << group_node.generate()
          end
          return groups
        end
      end
    end
  end
end
