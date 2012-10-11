class String
  def to_hex
    bytes.map do |ch|
      if ch.chr.index(/^[a-z_]$/i)
        ch.chr
      else
        '\x%02x' % ch
      end
    end.join('')
  end
end