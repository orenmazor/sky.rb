class SkyDB
  class Message
    ##########################################################################
    #
    # Constants
    #
    ##########################################################################

    # The version of the message. This must be compatible with the server's
    # version for the client to work.
    VERSION = 1
    

    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the message.
    def initialize(name)
      @name = name
      @table = ""
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    ####################################
    # Name
    ####################################

    # The name of message being sent. This is defined by the subclass.
    attr_reader :name


    ####################################
    # Table
    ####################################

    # The name of the table the message is being sent to/from.
    attr_accessor :table

    def table=(value)
      @table = value.to_s
    end


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################

    ####################################
    # Validation
    ####################################

    # Validates that the message is ready to be sent. If any validation issues
    # are found then an error is raised.
    def validate!
      if table.nil? || table.empty?
        raise SkyDB::TableRequiredError.new('Table required')
      end
    end


    ####################################
    # Encoding
    ####################################

    # Encodes the message contents to a buffer.
    #
    # @param [IO] buffer  the buffer to write to.
    def encode(buffer)
      buffer.set_encoding(Encoding::BINARY, Encoding::BINARY)
      
      # Encode the header and body.
      encode_header(buffer)
      encode_body(buffer)
      
      # Debugging
      $stderr << "[#{name}]: #{body.string.to_hex}\n" if SkyDB.debug

      return nil
    end

    # Encodes the message header.
    #
    # @param [IO] buffer  the buffer to write the header to.
    def encode_header(buffer)
      buffer << [
        SkyDB::Message::VERSION,
        name,
        table
        ].to_msgpack
    end

    # Encodes the message body.
    #
    # @param [IO] buffer  the buffer to write the header to.
    def encode_body(buffer)
      # To be implemented by the subclass.
    end


    ####################################
    # Response processing
    ####################################

    # Performs any necessary post-processing on the response.
    #
    # @param [Object] response  
    def process_response(response)
      return response
    end
  end
end

require 'skydb/message/add_action'
require 'skydb/message/get_action'
require 'skydb/message/get_actions'

require 'skydb/message/add_property'
require 'skydb/message/get_property'
require 'skydb/message/get_properties'

require 'skydb/message/add_event'
require 'skydb/message/next_actions'

require 'skydb/message/multi'
