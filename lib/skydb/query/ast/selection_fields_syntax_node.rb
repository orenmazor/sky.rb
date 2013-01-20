class SkyDB
  class Query
    class Ast
      module SelectionFieldsSyntaxNode
        # Generates a list of selection fields.
        def generate
          fields = []
          Treetop.search(self, SelectionFieldSyntaxNode).each do |field_node|
            fields << field_node.generate()
          end
          return fields
        end
      end
    end
  end
end
