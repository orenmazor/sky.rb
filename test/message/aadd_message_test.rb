# encoding: binary
require 'test_helper'

class TestMessageAADD < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::AADD.new()
  end
  
  ######################################
  # Action
  ######################################

  def test_action
    @message.action = SkyDB::Action.new
    refute_nil @message.action
  end
  
  def test_invalid_action
    @message.action = "foo"
    assert_nil @message.action
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.action = SkyDB::Action.new(0, "foo")
    @message.encode(buffer)
    assert_bytes "\x95\x01\xce\x00\x03\x00\x01\x0e\xa0\xa0\x82\xa2id\x00\xa4name\xa3foo", buffer
  end
end
