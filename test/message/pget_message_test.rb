# encoding: binary
require 'test_helper'

class TestMessagePGET < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::PGET.new()
  end
  
  ######################################
  # Property ID
  ######################################

  def test_property_id
    @message.property_id = 12
    assert_equal 12, @message.property_id
  end
  
  def test_invalid_property_id
    @message.property_id = "foo"
    assert_equal 0, @message.property_id
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.property_id = 10
    @message.encode(buffer)
    assert_bytes "\x95\x01\xa4pget\x01\xa0\xa0\x0a", buffer
  end
end
