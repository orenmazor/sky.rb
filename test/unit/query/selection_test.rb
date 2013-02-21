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



  ######################################
  # Aggregation Generation
  ######################################

  def test_simple_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("foo, bar my_alias")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          target.foo = cursor.event.foo()
          target.my_alias = cursor.event.bar()
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end

  def test_count_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("count() bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          target.bar = (target.bar or 0) + 1
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end

  def test_sum_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("SUM(foo) bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          target.bar = (target.bar or 0) + cursor.event.foo()
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end

  def test_min_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("min(foo) bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          if(target.bar == nil or target.bar > cursor.event.foo()) then
            target.bar = cursor.event.foo()
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end

  def test_max_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("max(foo) bar")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          if(target.bar == nil or target.bar < cursor.event.foo()) then
            target.bar = cursor.event.foo()
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end

  def test_grouped_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("foo, bar my_alias")
    @selection.groups = SkyDB::Query::Selection.parse_groups("baz")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          
          group_value = cursor.event.baz()
          if target[group_value] == nil then
            target[group_value] = {}
          end
          target = target[group_value]
          
          target.foo = cursor.event.foo()
          target.my_alias = cursor.event.bar()
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end

  def test_multiple_group_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("foo, bar my_alias")
    @selection.groups = SkyDB::Query::Selection.parse_groups("aaa, bbb, ccc")
    expected =
      <<-BLOCK.unindent
        function select(cursor, data)
          target = data
          
          group_value = cursor.event.aaa()
          if target[group_value] == nil then
            target[group_value] = {}
          end
          target = target[group_value]
          
          group_value = cursor.event.bbb()
          if target[group_value] == nil then
            target[group_value] = {}
          end
          target = target[group_value]
          
          group_value = cursor.event.ccc()
          if target[group_value] == nil then
            target[group_value] = {}
          end
          target = target[group_value]
          
          target.foo = cursor.event.foo()
          target.my_alias = cursor.event.bar()
        end
      BLOCK
    assert_equal expected, @selection.codegen_select()
  end


  ######################################
  # Merge Codegen
  ######################################

  def test_simple_merge_codegen
    @selection.fields = SkyDB::Query::Selection.parse_fields("foo, sum(bar) my_alias, count(), min(x), max(y)")
    expected =
      <<-BLOCK.unindent
        function merge(results, data)
          a = results
          b = data
          a.foo = b.foo
          a.my_alias = (a.my_alias or 0) + (b.my_alias or 0)
          a.count = (a.count or 0) + (b.count or 0)
          if(a.x == nil or a.x > b.x) then
            a.x = b.x
          end
          if(a.y == nil or a.y < b.y) then
            a.y = b.y
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen_merge()
  end

  def test_grouped_merge_codegen
    @selection = SkyDB::Query::Selection.new.select("sum(foo), count()").group_by(:bar)
    expected =
      <<-BLOCK.unindent
        function merge(results, data)
          for k0,v0 in pairs(data) do
            if results[k0] == nil then results[k0] = {} end
            a = results[k0]
            b = data[k0]
            a.foo = (a.foo or 0) + (b.foo or 0)
            a.count = (a.count or 0) + (b.count or 0)
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen_merge()
  end
  
  def test_multigroup_merge_codegen
    @selection = SkyDB::Query::Selection.new.select("sum(foo), count()").group_by(:bar, :baz)
    expected =
      <<-BLOCK.unindent
        function merge(results, data)
          for k0,v0 in pairs(data) do
            if results[k0] == nil then results[k0] = {} end
            for k1,v1 in pairs(data[k0]) do
              if results[k0][k1] == nil then results[k0][k1] = {} end
              a = results[k0][k1]
              b = data[k0][k1]
              a.foo = (a.foo or 0) + (b.foo or 0)
              a.count = (a.count or 0) + (b.count or 0)
            end
          end
        end
      BLOCK
    assert_equal expected, @selection.codegen_merge()
  end
end
