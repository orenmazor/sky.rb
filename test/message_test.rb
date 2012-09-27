# encoding: binary
require 'test_helper'

class TestMessage < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message.new(1)
  end
  
  def test_encode
    buffer = StringIO.new
    @message.database = "foo"
    @message.table = "users"
    @message.encode(buffer)
    assert_bytes "\x95\x01\x01\x00\xa3foo\xa5users", buffer
  end
end
