# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    SkyDB.debug = true
    WebMock.disable!
    @client = SkyDB::Client.new()
    @table = SkyDB::Table.new(:name => 'sky-rb-integration')
    begin; @client.delete_table(@table); rescue; end
  end

  def teardown
    begin; @client.delete_table(@table); rescue; end
  end

  
  ##############################################################################
  #
  # Tests
  #
  ##############################################################################

  def test_simple_count_query
    @client.create_table(@table)
    @client.create_property(@table, :name => 'action', :transient => true, :data_type => 'factor')
    @client.add_event(@table, "count0", :timestamp => DateTime.iso8601('2013-01-01T00:00:00Z'), :data => {'action' => "A0"})
    @client.add_event(@table, "count0", :timestamp => DateTime.iso8601('2013-01-01T00:00:01Z'), :data => {'action' => "A1"})
    @client.add_event(@table, "count0", :timestamp => DateTime.iso8601('2013-01-01T00:00:02Z'), :data => {'action' => "A2"})
    @client.add_event(@table, "count1", :timestamp => DateTime.iso8601('2013-01-01T00:00:00Z'), :data => {'action' => "A1"})
    @client.add_event(@table, "count1", :timestamp => DateTime.iso8601('2013-01-01T00:00:05Z'), :data => {'action' => "A2"})
    results = @client.query(@table, {steps:[{:type => 'selection', :alias => 'count', :expression => 'count()'}]})
    @client.delete_table(@table)
    assert_equal({'count' => 5}, results)
  end

  def test_funnel_query
    @client.create_table(@table)
    @client.create_property(@table, :name => 'action', :transient => true, :data_type => 'factor')
    @client.add_event(@table, "fun0", :timestamp => DateTime.iso8601('2013-01-01T00:00:00Z'), :data => {'action' => "A0"})
    @client.add_event(@table, "fun0", :timestamp => DateTime.iso8601('2013-01-01T00:00:01Z'), :data => {'action' => "A1"})
    @client.add_event(@table, "fun0", :timestamp => DateTime.iso8601('2013-01-01T00:00:02Z'), :data => {'action' => "A2"})
    @client.add_event(@table, "fun1", :timestamp => DateTime.iso8601('2013-01-01T00:00:00Z'), :data => {'action' => "A0"})
    @client.add_event(@table, "fun1", :timestamp => DateTime.iso8601('2013-01-01T00:00:05Z'), :data => {'action' => "A1"})
    @client.add_event(@table, "fun1", :timestamp => DateTime.iso8601('2013-01-01T00:00:10Z'), :data => {'action' => "A3"})
    results = @client.query(@table, {
      steps:[
        {:type => 'condition', :expression => 'action == "A0"', :steps => [
          {:type => 'condition', :expression => 'action == "A1"', :within => [1,1], :steps => [
            {:type => 'condition', :expression => 'true', :within => [1,1], :steps => [
              {:type => 'selection', :dimensions => ['action'], :alias => 'count', :expression => 'count()'}
            ]}
          ]}
        ]}
      ]
    })
    @client.delete_table(@table)
    assert_equal({"action"=>{"A2"=>{"count"=>1}, "A3"=>{"count"=>1}}}, results)
  end
end
