# encoding: binary
require 'test_helper'

class TestMessageLuaMapReduce < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::Lua::MapReduce.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.source = "function map(cursor) return {} end"
    @message.encode(buffer)
    assert_bytes "\x93\x01\xaflua::map_reduce\xa0\x81\xa6source\xda\x00\x22" + "function map(cursor) return {} end", buffer
  end
end
