class Hash
  # Performs a deep conversion of string keys to symbol keys.
  def _symbolize_keys!
    keys.select {|key| key.is_a?(String)}.each do |key|
      self[key]._symbolize_keys! if self[key].is_a?(Hash)
      self[(key.to_sym rescue key) || key] = self.delete(key)
    end

    return self
  end
end