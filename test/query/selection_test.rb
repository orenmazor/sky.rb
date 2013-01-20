require 'test_helper'

class TestQuerySelection < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @selection = SkyDB::Query::Selection.new()
  end


  ##############################################################################
  #
  # Tests
  #
  ##############################################################################

  ######################################
  # Field parsing
  ######################################

  def test_parse_single_field
    fields = SkyDB::Query::Selection.parse_fields("foo")
    assert_equal 1, fields.length
    assert_equal "foo", fields[0].expression
  end

  def test_parse_multiple_fields
    fields = SkyDB::Query::Selection.parse_fields("  foo  , bar, baz_12  ")
    assert_equal 3, fields.length
    assert_equal "foo", fields[0].expression
    assert_equal "bar", fields[1].expression
    assert_equal "baz_12", fields[2].expression
  end

  def test_parse_aliased_fields
    fields = SkyDB::Query::Selection.parse_fields("foo bar, baz bat")
    assert_equal 2, fields.length
    assert_equal "foo", fields[0].expression
    assert_equal "bar", fields[0].alias_name
    assert_equal "baz", fields[1].expression
    assert_equal "bat", fields[1].alias_name
  end

  def test_parse_aggregated_fields
    fields = SkyDB::Query::Selection.parse_fields("sum(foo), MIN(bar)")
    assert_equal 2, fields.length
    assert_equal "foo", fields[0].expression
    assert_equal :sum, fields[0].aggregation_type
    assert_equal "bar", fields[1].expression
    assert_equal :min, fields[1].aggregation_type
  end

  def test_parse_aliased_aggregated_fields
    fields = SkyDB::Query::Selection.parse_fields("sum(foo) baz, MIN(bar) bat")
    assert_equal 2, fields.length
    assert_equal "foo", fields[0].expression
    assert_equal "baz", fields[0].alias_name
    assert_equal :sum, fields[0].aggregation_type
    assert_equal "bar", fields[1].expression
    assert_equal "bat", fields[1].alias_name
    assert_equal :min, fields[1].aggregation_type
  end


  ######################################
  # Group parsing
  ######################################

  def test_parse_single_group
    groups = SkyDB::Query::Selection.parse_groups("foo")
    assert_equal 1, groups.length
    assert_equal "foo", groups[0].expression
  end

  def test_parse_multiple_groups
    groups = SkyDB::Query::Selection.parse_groups("foo, bar")
    assert_equal 2, groups.length
    assert_equal "foo", groups[0].expression
    assert_equal "bar", groups[1].expression
  end

  def test_parse_aliased_groups
    groups = SkyDB::Query::Selection.parse_groups("foo bar, baz bat_12")
    assert_equal 2, groups.length
    assert_equal "foo", groups[0].expression
    assert_equal "bar", groups[0].alias_name
    assert_equal "baz", groups[1].expression
    assert_equal "bat_12", groups[1].alias_name
  end



  ######################################
  # Code Generation
  ######################################

  def test_simple_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("foo, bar my_alias")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          data.foo = data.foo
          data.my_alias = data.bar
        end
      BLOCK
    assert_equal expected, @selection.codegen()
  end

  def test_count_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("count() bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          data.bar = (data.bar || 0) + 1
        end
      BLOCK
    assert_equal expected, @selection.codegen()
  end

  def test_sum_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("SUM(foo) bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          data.bar = (data.bar || 0) + cursor.event.foo
        end
      BLOCK
    assert_equal expected, @selection.codegen()
  end

  def test_min_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("min(foo) bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          if(data.bar == nil || data.bar > cursor.event.foo) then
            data.bar = cursor.event.foo
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen()
  end

  def test_max_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("min(foo) bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          if(data.bar == nil || data.bar > cursor.event.foo) then
            data.bar = cursor.event.foo
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen()
  end
end
