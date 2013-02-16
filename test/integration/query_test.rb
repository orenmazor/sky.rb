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
  # Aggregation
  ######################################

  def test_select_count
    import("integration/query/count.json")
    results = SkyDB.select('count()').execute()
    assert_equal ({"count" => 7}), results
  end

  def test_select_count_by_action_id
    import("integration/query/count.json")
    results = SkyDB.select('count()').group_by("action_id").execute()
    assert_equal({
      1=>{"count"=>2},  # /
      2=>{"count"=>1},  # /signup
      3=>{"count"=>2},  # /login
      4=>{"count"=>1},  # /about
      5=>{"count"=>1}   # /cancel_account
    }, results)
  end


  ######################################
  # Sessions
  ######################################

  def test_select_count_by_action_id_on_enter
    import("integration/query/count.json")
    results = SkyDB.select('count()')
      .group_by("action_id")
      .on(:enter)
      .execute()
    assert_equal ({1 => {"count" => 2}}), results
  end

  def test_select_count_by_action_id_on_enter_and_after
    import("integration/query/count.json")
    results = SkyDB.select('count()')
      .group_by("action_id")
      .on(:enter)
      .after("/")
      .execute()
    assert_equal ({2=>{"count"=>1}, 3=>{"count"=>1}}), results
  end

  def test_select_count_by_action_id_on_enter_and_after_sessionized
    import("integration/query/count.json")
    query = SkyDB.query.session(7200)
    results = query.select('count()')
      .group_by("action_id")
      .on(:enter)
      .after("/login")
      .execute()
    assert_equal ({"exit"=>{"count"=>1}, 5=>{"count"=>1}}), results
  end

  def test_select_count_by_action_id_on_enter_and_after_within_sessionized
    import("integration/query/count.json")
    query = SkyDB.query.session(7200)
    results = query.select('count()')
      .group_by("action_id")
      .on(:enter)
      .after(:action => "/", :within => {:quantity => 1, :unit => 'step'})
      .after(:action => "/login", :within => {:quantity => 1, :unit => 'step'})
      .execute()
    assert_equal ({5=>{"count"=>1}}), results
  end

  def test_double_after
    import("integration/query/double_after.json")
    query = SkyDB.query.session(7200)
    results = query.select('count()')
      .group_by("action_id")
      .on(:enter)
      .after(:action => "/", :within => {:quantity => 1, :unit => 'step'})
      .after(:action => "/login", :within => {:quantity => 1, :unit => 'step'})
      .after(:action => "/login", :within => {:quantity => 1, :unit => 'step'})
      .execute()
    assert_equal ({"exit"=>{"count"=>1}}), results
  end
end
