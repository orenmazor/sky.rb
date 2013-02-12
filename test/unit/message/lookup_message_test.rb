# encoding: binary
require 'test_helper'

class TestMessageLookup < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::Lookup.new()
  end
  
  ######################################
  # Encoding
  ######################################

  def test_encode
    buffer = StringIO.new
    @message.actions = [
      SkyDB::Action.new(:name => 'foo'),
      SkyDB::Action.new(:name => 'bar'),
    ]
    @message.properties = [
      SkyDB::Property.new(:name => 'xxx'),
      SkyDB::Property.new(:name => 'yyy'),
      SkyDB::Property.new(:name => 'zzz'),
    ]
    @message.encode(buffer)
    assert_bytes "\x93\x01\xa6lookup\xa0\x82\xabactionNames\x92\xa3foo\xa3bar\xadpropertyNames\x93\xa3xxx\xa3yyy\xa3zzz", buffer
  end
end
