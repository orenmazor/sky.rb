require 'date'
require 'net/http'
require 'json'

class SkyDB
  ############################################################################
  #
  # Errors
  #
  ############################################################################

  class SkyError < StandardError; end

  ############################################################################
  #
  # Constants
  #
  ############################################################################

  CLIENT_PASSTHROUGH = [
    :host, :host=, :port, :port=,
    :create_table
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
    client.__send__(method.to_sym, *args, &block)
  end
end

require 'skydb/client'
require 'skydb/table'
require 'skydb/version'
