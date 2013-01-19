class SkyDB
  class Query
    class Ast
      module SelectionSyntaxNode
        # Generates the Selection object from the node.
        def generate
          selection = SkyDB::Query::Selection.new()
          Treetop.search(self, SelectionFieldSyntaxNode).each do |field_node|
            selection.fields << field_node.generate()
          end
          return selection
        end
      end
    end
  end
end
