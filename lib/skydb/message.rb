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
    def initialize(type)
      @type = type
      @database = ""
      @table = ""
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    ####################################
    # Type
    ####################################

    # The type of message being sent. This is defined by the subclass.
    attr_reader :type


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
      
      return nil
    end

    # Encodes the message header.
    #
    # @param [IO] buffer  the buffer to write the header to.
    # @param [Fixnum] length  the length of the body, in bytes.
    def encode_header(buffer, length)
      buffer << [
        SkyDB::Message::VERSION,
        type,
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
    # Decoding
    ####################################

    # Decodes the message contents from a buffer.
    #
    # @param [IO] buffer  the buffer to read from.
    def decode(buffer)
      # TODO
    end
  end
end