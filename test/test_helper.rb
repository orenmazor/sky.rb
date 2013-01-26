require 'simplecov'
SimpleCov.start do
  add_group "Messages", "skydb/message"
  add_group "Query", "skydb/query"
  add_group "Importer", "skydb/import"
end

require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'unindentable'
require 'skydb'
require 'skydb/import'

class MiniTest::Unit::TestCase
  def assert_bytes exp, act, msg = nil
    exp = exp.to_hex
    act = act.string.to_hex
    assert_equal(exp, act, msg)
  end
end

