# encoding: binary
require 'test_helper'

class TestMessageEADD < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::EADD.new()
  end
  
  ######################################
  # Encoding
  ######################################
  
  def test_encode
    buffer = StringIO.new
    @message.table = "users"
    @message.event = SkyDB::Event.new(
      object_id: 12,
      timestamp:DateTime.parse('2010-01-02T10:30:20Z'),
      action_id:100,
      data: {
        my_string: "bar",
        my_int: 10,
        my_float: 100.1,
        my_true: true,
        my_false: false
      }
    )
    @message.encode(buffer)
    assert_bytes "\x93\x01\xa4eadd\xa5users\x84\xa8objectId\x0c\xa9timestamp\xcf\x00\x04\x7c\x2b\xf9\x9b\x87\x00\xa8actionIdd\xa4data\x85\xa9my_string\xa3bar\xa6my_int\x0a\xa8my_float\xcb\x40Y\x06fffff\xa7my_true\xc3\xa8my_false\xc2", buffer
  end
end
