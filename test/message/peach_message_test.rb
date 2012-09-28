# encoding: binary
require 'test_helper'

class TestMessagePEACH < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::PEACH.new()
  end
  
  ######################################
  # Object ID
  ######################################
  
  def test_query
    @message.query = "foo"
    assert_equal "foo", @message.query
  end
  
  def test_invalid_query
    @message.query = 12
    assert_equal '12', @message.query
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.query = "foo"
    @message.encode(buffer)
    assert_bytes "\x95\x01\xa5peach\x04\xa0\xa0\xa3foo", buffer
  end
end
