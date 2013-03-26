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
  # Static Attributes
  #
  ############################################################################

  ######################################
  # Debugging
  ######################################

  class << self
    attr_accessor :debug
  end
end

require 'skydb/client'
require 'skydb/property'
require 'skydb/table'
require 'skydb/version'
