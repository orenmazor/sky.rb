# encoding: binary
require 'test_helper'

class TestMessage < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message.new('xyz')
  end
  
  def test_encode
    buffer = StringIO.new
    @message.table = "users"
    @message.encode(buffer)
    assert_bytes "\x93\x01\xa3xyz\xa5users", buffer
  end
end
