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

class SkyDB
  ############################################################################
  #
  # Static Attributes
  #
  ############################################################################

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
    if [:eadd, :peach, :aadd, :aall, :aget, :padd, :pall, :pget].include?(method.to_sym)
      client.__send__(method.to_sym, *args)
    else
      raise NoMethodError.new("Message type not available: #{method}")
    end
  end
end