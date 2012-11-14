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
    assert_bytes "\x93\x01\xa5multi\xa0\x81\xa5count\x02" + "\x93\x01\xacget_property\xa0\x0c" + "\x93\x01\xaaget_action\xa0\xcc\xc8", buffer
  end
end