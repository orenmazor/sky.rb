# encoding: binary
require 'test_helper'

class TestMessage < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message.new('xyz')
  end
  
  def test_encode
    buffer = StringIO.new
    @message.database = "foo"
    @message.table = "users"
    @message.encode(buffer)
    assert_bytes "\x94\x01\xa3xyz\xa3foo\xa5users", buffer
  end
end
