# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  def setup
    @client = SkyDB::Client.new(host:'127.0.0.1', port:9000)
    @message = mock('message')
  end
  
  ######################################
  # Send
  ######################################

  def test_send_message
    socket = StringIO.new("\xa3foo")
    TCPSocket.expects(:new).with('127.0.0.1', 9000).returns(socket)
    @message.expects(:encode).with(socket)
    @message.expects(:process_response).with("foo").returns("bar")
    assert_equal 'bar', @client.send_message(@message)
  end
end
