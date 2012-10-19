# encoding: binary
require 'test_helper'

class TestMessageAddAction < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::AddAction.new()
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
    @message.action = SkyDB::Action.new(:id => 0, :name => "foo")
    @message.encode(buffer)
    assert_bytes "\x94\x01\xaaadd_action\xa0\xa0\x82\xa2id\x00\xa4name\xa3foo", buffer
  end
end
