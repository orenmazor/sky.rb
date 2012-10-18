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
      @database = ""
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
    # Database
    ####################################

    # The name of the database the message is being sent to/from.
    attr_reader :database
    
    def database=(value)
      @database = value.to_s
    end


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
      if database.nil? || database.empty?
        raise SkyDB::DatabaseRequiredError.new('Database required')
      end
      
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
      
      # Encode the body first to determine the size of the contents.
      body = StringIO.new()
      encode_body(body)
      
      # Encode the header and append the body.
      encode_header(buffer, body.length)
      buffer << body.string
      
      # Debugging
      $stderr << "[#{name}]: #{body.string.to_hex}\n" if SkyDB.debug

      return nil
    end

    # Encodes the message header.
    #
    # @param [IO] buffer  the buffer to write the header to.
    # @param [Fixnum] length  the length of the body, in bytes.
    def encode_header(buffer, length)
      buffer << [
        SkyDB::Message::VERSION,
        name,
        length,
        database,
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

require 'skydb/message/aadd'
require 'skydb/message/aall'
require 'skydb/message/aget'

require 'skydb/message/padd'
require 'skydb/message/pall'
require 'skydb/message/pget'

require 'skydb/message/eadd'
require 'skydb/message/next_action'

require 'skydb/message/multi'
