require 'date'
require 'msgpack'
require 'socket'
require 'treetop'

require 'skydb/action'
require 'skydb/client'
require 'skydb/event'
require 'skydb/message'
require 'skydb/property'
require 'skydb/query'
require 'skydb/table'
require 'skydb/timestamp'
require 'skydb/version'

require 'ext/hash'
require 'ext/string'
require 'ext/treetop'

class SkyDB
  ############################################################################
  #
  # Errors
  #
  ############################################################################

  class TableRequiredError < StandardError; end

  class ObjectIdRequiredError < StandardError; end
  class TimestampRequiredError < StandardError; end

  ############################################################################
  #
  # Constants
  #
  ############################################################################

  CLIENT_PASSTHROUGH = [
    :host, :host=, :port, :port=,
    :table_name, :table_name=,
    :multi, :ping, :lookup,
    :add_event,
    :create_table, :delete_table, :get_table, :get_tables,
    :add_action, :get_action, :get_actions,
    :add_property, :get_property, :get_properties,
    :next_actions,
    :aggregate,
    :select
  ]
  
  
  ############################################################################
  #
  # Static Attributes
  #
  ############################################################################

  ######################################
  # Debugging
  ######################################

  class << self
    attr_accessor :debug
  end

  ######################################
  # Default Client
  ######################################
  
  # The default Sky client.
  def self.client
    @client ||= SkyDB::Client.new()
    return @client
  end

  def self.client=(value)
    @client = value
  end
  

  ############################################################################
  #
  # Static Methods
  #
  ############################################################################

  def self.method_missing(method, *args, &block)
    method = method
    if CLIENT_PASSTHROUGH.include?(method.to_sym)
      client.__send__(method.to_sym, *args, &block)
    else
      raise NoMethodError.new("Message type not available: #{method}")
    end
  end
end