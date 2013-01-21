require 'test_helper'

class TestQueryAfter < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @after = SkyDB::Query::After.new()
  end


  ##############################################################################
  #
  # Tests
  #
  ##############################################################################

  ######################################
  # Validation
  ######################################

  def test_validate_action
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::After.new(:function_name => "foo").validate!
    end
    assert_match /^Action with non-zero identifier required/, e.message
  end
  
  def test_validate_function_name
    e = assert_raises(SkyDB::Query::ValidationError) do
      SkyDB::Query::After.new(:action => 10).validate!
    end
    assert_match /^Invalid function name ''/, e.message
  end
  
  
  ######################################
  # Code Generation
  ######################################

  def test_codegen
    @after = SkyDB::Query::After.new(:action => 10, :function_name => "foo")
    expected =
      <<-BLOCK.unindent
        function foo(cursor, data)
          repeat
            if cursor.event.action_id == 10 then
              cursor:next()
              return true
            end
          until not cursor:next()
          return false
        end
      BLOCK
    assert_equal expected, @after.codegen()
  end
end
