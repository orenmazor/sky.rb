# encoding: binary
require 'test_helper'

class TestMessageMulti < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::Multi.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.messages = [
      SkyDB::Message::GetProperty.new(12),
      SkyDB::Message::GetAction.new(200)
      ]
    @message.encode(buffer)
    assert_bytes "\x95\x01\xa5multi\x26\xa0\xa0\x02" + "\x95\x01\xacget_property\x01\xa0\xa0\x0c" + "\x95\x01\xaaget_action\x02\xa0\xa0\xcc\xc8", buffer
  end
end
