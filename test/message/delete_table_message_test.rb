# encoding: binary
require 'test_helper'

class TestMessageDeleteTable < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::DeleteTable.new()
  end
  
  ######################################
  # Action
  ######################################

  def test_table
    @message.table = SkyDB::Table.new('foo')
    refute_nil @message.table
  end
  
  def test_invalid_table
    @message.table = "foo"
    assert_nil @message.table
  end
  

  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.table = SkyDB::Table.new("foo")
    @message.encode(buffer)
    assert_bytes "\x93\x01\xacdelete_table\xa0\x81\xa4name\xa3foo", buffer
  end
end
