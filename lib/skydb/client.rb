class SkyDB
  class Client
    ##########################################################################
    #
    # Constants
    #
    ##########################################################################

    # The default host to connect to if one is not specified.
    DEFAULT_HOST = 'localhost'

    # The default port to connect to if one is not specified.
    DEFAULT_PORT = 8585


    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the client.
    def initialize(options={})
      self.host = options[:host] || DEFAULT_HOST
      self.port = options[:port] || DEFAULT_PORT
    end


    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The name of the host to conect to.
    attr_accessor :host

    # The port on the host to connect to.
    attr_accessor :port


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    # Sends a message to the server.
    #
    # @param [SkyDB::Message] message  the message to send.
    # @return [Object]  the object returned by the server.
    def send_message(message)
      # Connect to the server.
      puts "XXXXX #{host}:#{port.to_i}"
      socket = TCPSocket.new(host, port.to_i)
      
      # Encode and send message request.
      message.encode(socket)
      
      # Decode msgpack response. There should only be one return object.
      response = nil
      unpacker = MessagePack::Unpacker.new(socket)
      unpacker.each do |obj|
        response = obj
        break
      end
      
      # TODO: Exception processing.
      
      # Process response back through the message.
      response = message.process_response(response)
      
      # Return response.
      return response
    end
  end
end