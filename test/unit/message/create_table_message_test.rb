# encoding: binary
require 'test_helper'

class TestMessageCreateTable < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::CreateTable.new()
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
    @message.table = SkyDB::Table.new("foo", :tablet_count => 8)
    @message.encode(buffer)
    assert_bytes "\x93\x01\xaccreate_table\xa0\x82\xa4name\xa3foo\xactablet_count\x08", buffer
  end
end
