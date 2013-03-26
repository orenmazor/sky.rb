# encoding: binary
require 'test_helper'

class TestClient < MiniTest::Unit::TestCase
  ##############################################################################
  #
  # Setup / Teardown
  #
  ##############################################################################

  def setup
    @client = SkyDB::Client.new()
    @table = SkyDB::Table.new(:name => 'foo')
  end

  
  ######################################
  # Table API
  ######################################

  def test_create_table
    stub_request(:post, "http://localhost:8585/tables")
      .with(:body => '{"name":"foo"}')
      .to_return(:status => 200, :body => '{"name":"foo"}')

    table = @client.create_table(SkyDB::Table.new(:name => 'foo'))
    assert_equal("foo", table.name)
  end

  def test_delete_table
    stub_request(:delete, "http://localhost:8585/tables/foo").to_return(:status => 200)
    @client.delete_table(SkyDB::Table.new(:name => 'foo'))
  end


  ######################################
  # Property API
  ######################################

  def test_get_properties
    stub_request(:get, "http://localhost:8585/tables/foo/properties")
      .to_return(:status => 200, :body => '[{"id":-1,"name":"action","transient":true,"dataType":"string"},{"id":1,"name":"first_name","transient":false,"dataType":"integer"}]')
    properties = @client.get_properties(@table)
    assert_equal(2, properties.length)
    assert_equal("action", properties[0].name)
    assert_equal("first_name", properties[1].name)
  end

  def test_get_property
    stub_request(:get, "http://localhost:8585/tables/foo/properties/action")
      .to_return(:status => 200, :body => '{"id":-1,"name":"action","transient":true,"dataType":"string"}')
    property = @client.get_property(@table, "action")
    assert_equal("action", property.name)
  end

  def test_create_property
    stub_request(:post, "http://localhost:8585/tables/foo/properties")
      .with(:body => '{"name":"action","transient":true,"dataType":"string"}')
      .to_return(:status => 200, :body => '{"id":-1,"name":"action","transient":true,"dataType":"string"}')
    property = @client.create_property(@table, SkyDB::Property.new(:name => 'action', :transient => true, :data_type => 'string'))
    assert_equal("action", property.name)
    assert_equal(true, property.transient)
    assert_equal("string", property.data_type)
  end

  def test_update_property
    stub_request(:patch, "http://localhost:8585/tables/foo/properties/action2")
      .with(:body => '{"name":"action2","transient":true,"dataType":"string","id":-1}')
      .to_return(:status => 200, :body => '{"id":-1,"name":"action2","transient":true,"dataType":"string"}')
    property = @client.update_property(@table, SkyDB::Property.new(:id => -1, :name => 'action2', :transient => true, :data_type => 'string'))
    assert_equal("action2", property.name)
  end

  def test_delete_property
    stub_request(:delete, "http://localhost:8585/tables/foo/properties/action")
      .to_return(:status => 200)
    @client.delete_property(@table, SkyDB::Property.new(:name => 'action'))
  end


  ######################################
  # Event API
  ######################################

  def test_get_events
    stub_request(:get, "http://localhost:8585/tables/foo/objects/xxx/events")
      .to_return(:status => 200, :body => '[{"timestamp":"1970-01-01T00:00:00Z","data":{"action":"/home"}},{"timestamp":"1970-01-01T00:00:00.5Z","data":{"action":"/pricing"}}]')
    events = @client.get_events(@table, "xxx")
    assert_equal(2, events.length)
    assert_equal("1970-01-01T00:00:00.000000Z", events[0].formatted_timestamp)
    assert_equal({'action' => '/home'}, events[0].data)
    assert_equal("1970-01-01T00:00:00.500000Z", events[1].formatted_timestamp)
    assert_equal({'action' => '/pricing'}, events[1].data)
  end

  def test_get_event
    stub_request(:get, "http://localhost:8585/tables/foo/objects/xxx/events/1970-01-01T00:00:00.000000Z")
      .to_return(:status => 200, :body => '{"timestamp":"1970-01-01T00:00:00.000000Z","data":{"action":"/home"}}')
    event = @client.get_event(@table, "xxx", DateTime.iso8601('1970-01-01T00:00:00Z'))
    assert_equal("1970-01-01T00:00:00.000000Z", event.formatted_timestamp)
    assert_equal({'action' => '/home'}, event.data)
  end

  def test_replace_event
    stub_request(:put, "http://localhost:8585/tables/foo/objects/xxx/events/1970-01-01T00:00:00.000000Z")
      .with(:body => '{"timestamp":"1970-01-01T00:00:00.000000Z","data":{"action":"/home"}}')
      .to_return(:status => 200, :body => '{"timestamp":"1970-01-01T00:00:00.000000Z","data":{"action":"/home"}}')
    event = SkyDB::Event.new(:timestamp => DateTime.iso8601('1970-01-01T00:00:00Z'), :data => {'action' => '/home'})
    event = @client.add_event(@table, "xxx", event, :method => :replace)
    assert_equal("1970-01-01T00:00:00.000000Z", event.formatted_timestamp)
    assert_equal({'action' => '/home'}, event.data)
  end

  def test_merge_event
    stub_request(:patch, "http://localhost:8585/tables/foo/objects/xxx/events/1970-01-01T00:00:00.000000Z")
      .with(:body => '{"timestamp":"1970-01-01T00:00:00.000000Z","data":{"action":"/home"}}')
      .to_return(:status => 200, :body => '{"timestamp":"1970-01-01T00:00:00.000000Z","data":{"action":"/home","first_name":"bob"}}')
    event = SkyDB::Event.new(:timestamp => DateTime.iso8601('1970-01-01T00:00:00Z'), :data => {'action' => '/home'})
    event = @client.add_event(@table, "xxx", event, :method => :merge)
    assert_equal("1970-01-01T00:00:00.000000Z", event.formatted_timestamp)
    assert_equal({'action' => '/home', 'first_name' => 'bob'}, event.data)
  end

  def test_delete_event
    stub_request(:delete, "http://localhost:8585/tables/foo/objects/xxx/events/1970-01-01T00:00:00.000000Z")
      .to_return(:status => 200)
    @client.delete_event(@table, "xxx", SkyDB::Event.new(:timestamp => DateTime.iso8601('1970-01-01T00:00:00Z')))
  end


  ######################################
  # Query API
  ######################################

  def test_query
    stub_request(:post, "http://localhost:8585/tables/foo/query")
      .with(:body => '{"steps":[{"type":"selection","alias":"count","expression":"count()"}]}')
      .to_return(:status => 200, :body => '{"count":5}'+"\n")
    results = @client.query(@table, {:steps => [:type => 'selection', :alias => 'count', :expression => 'count()']})
    assert_equal({'count' => 5}, results)
  end


  ######################################
  # Utility API
  ######################################

  def test_successful_ping
    stub_request(:get, "http://localhost:8585/ping")
      .to_return(:status => 200, :body => '{"message":"ok"}')
    assert(@client.ping())
  end

  def test_unsuccessful_ping
    stub_request(:get, "http://localhost:8585/ping").to_timeout
    refute(@client.ping())
  end
end
