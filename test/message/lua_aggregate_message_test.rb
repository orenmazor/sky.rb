# encoding: binary
require 'test_helper'

class TestMessageLuaAggregate < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::Lua::Aggregate.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.source = "function aggregate(cursor, data) return {} end"
    @message.encode(buffer)
    assert_bytes "\x93\x01\xaelua::aggregate\xa0\x81\xa6source\xda\x00\x2e" + "function aggregate(cursor, data) return {} end", buffer
  end
end
