# encoding: binary
require 'test_helper'

class TestMessageGetProperties < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::GetProperties.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.encode(buffer)
    assert_bytes "\x93\x01\xaeget_properties\xa0", buffer
  end
end
