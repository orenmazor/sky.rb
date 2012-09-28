# encoding: binary
require 'test_helper'

class TestEvent < MiniTest::Unit::TestCase
  def setup
    @event = SkyDB::Event.new()
  end
  
  ######################################
  # Object ID
  ######################################
  
  def test_object_id
    @event.object_id = 12
    assert_equal 12, @event.object_id
  end
  
  def test_invalid_object_id
    @event.object_id = "foo"
    assert_equal 0, @event.object_id
  end
  

  ######################################
  # Timestamp
  ######################################
  
  def test_timestamp_with_time
    @event.timestamp = Time.now
    refute_nil @event.timestamp
  end
  
  def test_invalid_timestamp
    @event.object_id = "foo"
    assert_nil @event.timestamp
  end
end
