# encoding: binary
require 'test_helper'

class TestEvent < MiniTest::Unit::TestCase
  ######################################
  # Missing method
  ######################################
  
  def test_missing_method
    message = mock(message)
    SkyDB::Client.any_instance.expects(:add_event).with(message)
    SkyDB.add_event(message)
  end

  def test_invalid_missing_method
    assert_raises NoMethodError do
      SkyDB.no_such_msg_type
    end
  end
end
