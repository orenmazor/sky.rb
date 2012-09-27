# encoding: binary
require 'minitest/autorun'
require 'skydb'
require 'test_helper'

class TestMessageEADD < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::EADD.new()
  end
  
  def test_object_id
    @message.object_id = 12
    assert_equal 12, @message.object_id
  end
  
  def test_invalid_object_id
    @message.object_id = "foo"
    assert_equal 0, @message.object_id
  end
  
  def test_encode
    buffer = StringIO.new
    @message.database = "foo"
    @message.table = "users"
    @message.object_id = 12
    @message.timestamp = DateTime.parse('2010-01-02T10:30:20Z')
    @message.action_id = 100
    @message.data = {
      :my_string => "bar",
      :my_int => 10,
      :my_float => 100.1,
      :my_true => true,
      :my_false => false
    }
    @message.encode(buffer)
    assert_bytes "\x95\x01\xce\x00\x01\x00\x01i\xa3foo\xa5users\x84\xa8objectId\x0c\xa9timestamp\xcf\x00\x04\x7c\x2b\xf9\x9b\x87\x00\xa8actionIdd\xa4data\x85\xa9my_string\xa3bar\xa6my_int\x0a\xa8my_float\xcb\x40Y\x06fffff\xa7my_true\xc3\xa8my_false\xc2", buffer
  end
end
