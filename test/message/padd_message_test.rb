# encoding: binary
require 'test_helper'

class TestMessagePADD < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::PADD.new()
  end
  
  ######################################
  # Property
  ######################################

  def test_property
    @message.property = SkyDB::Property.new
    refute_nil @message.property
  end
  
  def test_invalid_property
    @message.property = "foo"
    assert_nil @message.property
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode_object_property
    buffer = StringIO.new
    @message.property = SkyDB::Property.new(0, :object, 'Int', 'foo')
    @message.encode(buffer)
    assert_bytes "\x95\x01\xce\x00\x04\x00\x01\x21\xa0\xa0\x84\xa2id\x00\xa4type\x01\xa8dataType\xa3Int\xa4name\xa3foo", buffer
  end

  def test_encode_action_property
    buffer = StringIO.new
    @message.property = SkyDB::Property.new(0, :action, 'Boolean', 'foo')
    @message.encode(buffer)
    assert_bytes "\x95\x01\xce\x00\x04\x00\x01\x25\xa0\xa0\x84\xa2id\x00\xa4type\x02\xa8dataType\xa7Boolean\xa4name\xa3foo", buffer
  end
end
