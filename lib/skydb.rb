require 'date'
require 'msgpack'
require 'socket'

require 'skydb/action'
require 'skydb/client'
require 'skydb/event'
require 'skydb/message'
require 'skydb/property'
require 'skydb/timestamp'
require 'skydb/version'

require 'ext/string'

class SkyDB
  ############################################################################
  #
  # Errors
  #
  ############################################################################

  class DatabaseRequiredError < StandardError; end
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
    :database, :database=, :table, :table=,
    :eadd, :next_action, :aadd, :aall, :aget, :padd, :pall, :pget
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

  def self.method_missing(method, *args)
    method = method
    if CLIENT_PASSTHROUGH.include?(method.to_sym)
      client.__send__(method.to_sym, *args)
    else
      raise NoMethodError.new("Message type not available: #{method}")
    end
  end
end