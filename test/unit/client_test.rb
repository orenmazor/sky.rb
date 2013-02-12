# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  def setup
    @client = SkyDB::Client.new(host:'127.0.0.1', port:9000)
    @message = mock('message')
  end
  
  ######################################
  # Action Messages
  ######################################

  def test_add_action
    action = SkyDB::Action.new
    @client.expects(:send_message).with(is_a(SkyDB::Message::AddAction))
    @client.add_action(action)
  end

  def test_get_action
    @client.expects(:send_message).with(is_a(SkyDB::Message::GetAction))
    @client.get_action(12)
  end

  def test_get_actions
    @client.expects(:send_message).with(is_a(SkyDB::Message::GetActions))
    @client.get_actions
  end


  ######################################
  # Property Messages
  ######################################

  def test_add_property
    property = SkyDB::Property.new
    @client.expects(:send_message).with(is_a(SkyDB::Message::AddProperty))
    @client.add_property(property)
  end

  def test_get_property
    @client.expects(:send_message).with(is_a(SkyDB::Message::GetProperty))
    @client.get_property(12)
  end

  def test_get_properties
    @client.expects(:send_message).with(is_a(SkyDB::Message::GetProperties))
    @client.get_properties
  end


  ######################################
  # Event Messages
  ######################################

  def test_add_event
    event = SkyDB::Event.new
    @client.expects(:send_message).with(is_a(SkyDB::Message::AddEvent))
    @client.add_event(event)
  end


  ######################################
  # Query Messages
  ######################################

  def test_next_actions
    @client.expects(:send_message).with(is_a(SkyDB::Message::NextActions))
    @client.next_actions([1, 2])
  end
end
