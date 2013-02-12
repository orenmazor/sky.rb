# encoding: binary
require 'test_helper'

class TestMessageGetTable < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::GetTable.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.name = "foo"
    @message.encode(buffer)
    assert_bytes "\x93\x01\xa9get_table\xa0\x81\xa4name\xa3foo", buffer
  end
end
