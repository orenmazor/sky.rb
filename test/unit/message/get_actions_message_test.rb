# encoding: binary
require 'test_helper'

class TestMessageGetActions < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::GetActions.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.encode(buffer)
    assert_bytes "\x93\x01\xabget_actions\xa0", buffer
  end
end
