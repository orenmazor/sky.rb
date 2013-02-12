require 'simplecov'
SimpleCov.start do
  add_group "Query", "skydb/query"
end

require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'unindentable'
require "stringio"
require 'skydb'
require 'skydb/import'

class MiniTest::Unit::TestCase
  # The name of the table to import into.
  def default_table_name; "sky-integration-tests"; end

  def assert_bytes exp, act, msg = nil
    exp = exp.to_hex
    act = act.string.to_hex
    assert_equal(exp, act, msg)
  end

  # Captures STDIN & STDERR and returns them as strings.
  def capture_io
    _stdout, $stdout = $stdout, StringIO.new
    _stderr, $stderr = $stderr, StringIO.new
    yield
    [$stdout.string, $stderr.string]
  ensure
    $stdout = _stdout
    $stderr = _stderr
  end

  def import(filename, options={})
    # Default options.
    options = {
      :table_name => default_table_name,
      :transform => 'sky'
    }.merge(options)
    
    # Prepend fixture directory.
    filename = File.expand_path(File.join(File.dirname(__FILE__), "../fixtures", filename))
    
    # Delete the table if it exists.
    table = SkyDB.get_table(options[:table_name])
    SkyDB.delete_table(SkyDB::Table.new(options[:table_name])) unless table.nil?
    SkyDB.create_table(SkyDB::Table.new(options[:table_name]))

    # Import.
    importer = SkyDB::Import::Importer.new()
    importer.table_name = options[:table_name]
    importer.load_transform_file(options[:transform]) unless options[:transform].nil?
    importer.import([filename], :progress_bar => false)
  end
end
