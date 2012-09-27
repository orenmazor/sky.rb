# encoding: binary
require 'test_helper'

class TestMessageAALL < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::AALL.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.encode(buffer)
    assert_bytes "\x95\x01\xce\x00\x03\x00\x05\x00\xa0\xa0", buffer
  end
end
