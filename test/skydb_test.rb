require 'minitest/autorun'
require 'skydb'

class TestSkyDB < MiniTest::Unit::TestCase
  def setup
    @skydb = SkyDB.new
  end
  
  def test_hello
    assert_equal "hello!", @skydb.hello
  end
end