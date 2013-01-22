require 'test_helper'

class TestQuery < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @query = SkyDB::Query.new()
  end


  ##############################################################################
  #
  # Tests
  #
  ##############################################################################

  ######################################
  # Select
  ######################################

  def test_select
    @query.select('foo, bar')
    assert_equal 'foo', @query.selection.fields[0].expression
    assert_equal 'bar', @query.selection.fields[1].expression
  end
  
  def test_select_array
    @query.select('foo', 'bar')
    assert_equal 'foo', @query.selection.fields[0].expression
    assert_equal 'bar', @query.selection.fields[1].expression
  end

  def test_select_mixed
    @query.select(:foo, :bar, 'baz, bat')
    assert_equal 'foo', @query.selection.fields[0].expression
    assert_equal 'bar', @query.selection.fields[1].expression
    assert_equal 'baz', @query.selection.fields[2].expression
    assert_equal 'bat', @query.selection.fields[3].expression
  end
  

  ######################################
  # Group by
  ######################################

  def test_group_by
    @query.select(:foo, :bar).group_by('baz, bat', :xxx)
    assert_equal 'foo', @query.selection.fields[0].expression
    assert_equal 'bar', @query.selection.fields[1].expression
    assert_equal 'baz', @query.selection.groups[0].expression
    assert_equal 'bat', @query.selection.groups[1].expression
    assert_equal 'xxx', @query.selection.groups[2].expression
  end
  
  
  ######################################
  # After
  ######################################

  def test_after
    @query.select('count()').after('foo')
    assert_equal :count, @query.selection.fields[0].aggregation_type
    assert_equal 'foo', @query.conditions[0].action.name
  end

  def test_after_with_hash
    @query.select('count()').after(:action => 'foo')
    assert_equal 'foo', @query.conditions[0].action.name
  end


  ######################################
  # Codegen
  ######################################

  def test_codegen
    @query.select('count()').after(10).after(20)
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          target.count = (target.count or 0) + 1
        end
        
        function __condition1(cursor, data)
          repeat
            if cursor.event.action_id == 10 then
              cursor:next()
              return true
            end
          until not cursor:next()
          return false
        end
        
        function __condition2(cursor, data)
          repeat
            if cursor.event.action_id == 20 then
              cursor:next()
              return true
            end
          until not cursor:next()
          return false
        end
        
        function aggregate(cursor, data)
          while cursor:next_session() do
            while cursor:next() do
              if __condition1(cursor, data) and __condition2(cursor, data) then
                select(cursor, data)
              end
            end
          end
        end

        function merge(results, data)
          a = results
          b = data
          a.count = (a.count or 0) + (b.count or 0)
        end
      BLOCK
    assert_equal expected.chomp, @query.codegen().chomp
  end

  def test_codegen_with_session
    @query.select('count()').session(7200)
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          target.count = (target.count or 0) + 1
        end
        
        function aggregate(cursor, data)
          cursor:set_session_idle(7200)
          while cursor:next_session() do
            while cursor:next() do
              if true then
                select(cursor, data)
              end
            end
          end
        end

        function merge(results, data)
          a = results
          b = data
          a.count = (a.count or 0) + (b.count or 0)
        end
      BLOCK
    assert_equal expected.chomp, @query.codegen().chomp
  end
end
