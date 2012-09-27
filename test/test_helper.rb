class MiniTest::Unit::TestCase
  def assert_bytes exp, act, msg = nil
    exp = exp.to_hex
    act = act.string.to_hex
    assert_equal(exp, act, msg)
  end
end

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