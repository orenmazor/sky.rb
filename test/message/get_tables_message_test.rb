# encoding: binary
require 'test_helper'

class TestMessageGetTables < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::GetTables.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.encode(buffer)
    assert_bytes "\x93\x01\xaaget_tables\xa0", buffer
  end
end
