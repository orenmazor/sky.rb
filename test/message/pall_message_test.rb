# encoding: binary
require 'test_helper'

class TestMessagePALL < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::PALL.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.encode(buffer)
    assert_bytes "\x95\x01\xa4pall\x00\xa0\xa0", buffer
  end
end
