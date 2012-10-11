require 'minitest/autorun'
require 'mocha'
require 'skydb'

class MiniTest::Unit::TestCase
  def assert_bytes exp, act, msg = nil
    exp = exp.to_hex
    act = act.string.to_hex
    assert_equal(exp, act, msg)
  end
end

