# encoding: binary
require 'test_helper'

class TestMessagePing < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::Ping.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.encode(buffer)
    assert_bytes "\x93\x01\xa4ping\xa0", buffer
  end
end
