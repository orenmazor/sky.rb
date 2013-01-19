module Treetop
  # Searches the syntax node hierarchy for elements that match a given class.
  def self.search(node, type)
    # If this is a matching node then return it.
    if node.is_a?(type)
      return [node]

    # Otherwise search children.
    elsif !node.elements.nil?
      ret = []
      node.elements.each do |element|
        ret = ret.concat(Treetop.search(element, type))
      end
      return ret
    end

    return []
  end
end