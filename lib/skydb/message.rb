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
    def initialize(message_name)
      @message_name = message_name
      @table_name = ""
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
    attr_reader :message_name


    ####################################
    # Table Name
    ####################################

    # The name of the table the message is being sent to/from.
    attr_accessor :table_name

    def table_name=(value)
      @table_name = value.to_s
    end


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################

    ####################################
    # Validation
    ####################################

    # A flag stating if the table is required for this type of message.
    def require_table?
      return true
    end

    # Validates that the message is ready to be sent. If any validation issues
    # are found then an error is raised.
    def validate!
      if require_table? && (table_name.nil? || table_name.empty?)
        raise SkyDB::TableRequiredError.new('Table name required')
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
      
      return nil
    end

    # Encodes the message header.
    #
    # @param [IO] buffer  the buffer to write the header to.
    def encode_header(buffer)
      buffer << [
        SkyDB::Message::VERSION,
        message_name,
        table_name
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

require 'skydb/message/create_table'
require 'skydb/message/delete_table'
require 'skydb/message/get_table'
require 'skydb/message/get_tables'

require 'skydb/message/add_action'
require 'skydb/message/get_action'
require 'skydb/message/get_actions'

require 'skydb/message/add_property'
require 'skydb/message/get_property'
require 'skydb/message/get_properties'

require 'skydb/message/add_event'
require 'skydb/message/next_actions'

require 'skydb/message/lua/aggregate'

require 'skydb/message/ping'
require 'skydb/message/lookup'
require 'skydb/message/multi'
