# encoding: binary
require 'test_helper'

class TestMessageAGET < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::AGET.new()
  end
  
  ######################################
  # Action
  ######################################

  def test_action_id
    @message.action_id = 12
    assert_equal 12, @message.action_id
  end
  
  def test_invalid_action_id
    @message.action_id = "foo"
    assert_equal 0, @message.action_id
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.action_id = 10
    @message.encode(buffer)
    assert_bytes "\x95\x01\xa4aget\x01\xa0\xa0\x0a", buffer
  end
end
