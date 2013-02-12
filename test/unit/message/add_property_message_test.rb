# encoding: binary
require 'test_helper'

class TestMessageAddProperty < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::AddProperty.new()
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
    @message.property = SkyDB::Property.new(:type => :object, :data_type => 'Int', :name => 'foo')
    @message.encode(buffer)
    assert_bytes "\x93\x01\xacadd_property\xa0\x84\xa2id\x00\xa4type\x01\xa8dataType\xa3Int\xa4name\xa3foo", buffer
  end

  def test_encode_action_property
    buffer = StringIO.new
    @message.property = SkyDB::Property.new(:type => :action, :data_type => 'Boolean', :name => 'foo')
    @message.encode(buffer)
    assert_bytes "\x93\x01\xacadd_property\xa0\x84\xa2id\x00\xa4type\x02\xa8dataType\xa7Boolean\xa4name\xa3foo", buffer
  end
end
