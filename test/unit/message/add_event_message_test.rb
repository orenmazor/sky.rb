# encoding: binary
require 'test_helper'

class TestMessageAddEvent < MiniTest::Unit::TestCase
  def setup
    @message = SkyDB::Message::AddEvent.new()
  end
  
  ######################################
  # Encoding
  ######################################
  
  def test_encode
    buffer = StringIO.new
    @message.table_name = "users"
    @message.event = SkyDB::Event.new(
      object_id: "12",
      timestamp:DateTime.parse('2010-01-02T10:30:20Z'),
      action: {
        name:"/index.html",
        astring:"foo",
        aint:20
      },
      data: {
        ostring: "bar",
        oint: 10,
        odouble: 100.1,
        otrue: true,
        ofalse: false
      }
    )
    @message.encode(buffer)
    assert_bytes "\x93\x01\xa9add_event\xa5users\x84\xa8objectId\xa3\xa212\xa9timestamp\xcf\x00\x04\x7c\x2b\xf9\x9b\x87\x00\xa6action\x83\xa4name\xab\x2findex\x2ehtml\xa7astring\xa3foo\xa4aint\x14\xa4data\x85\xa7ostring\xa3bar\xa4oint\x0a\xa7odouble\xcb\x40Y\x06fffff\xa5otrue\xc3\xa6ofalse\xc2", buffer
  end
end
