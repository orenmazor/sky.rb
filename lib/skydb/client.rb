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

    # The table to connect to.
    attr_accessor :table


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Action Messages
    ####################################

    # Adds an action to the server.
    #
    # @param [Action] action  the action to add.
    def add_action(action, options={})
      return send_message(SkyDB::Message::AddAction.new(action, options))
    end

    # Retrieves an individual action from the server.
    #
    # @param [Fixnum] action_id  the identifier of the action to retrieve.
    def get_action(action_id, options={})
      return send_message(SkyDB::Message::GetAction.new(action_id, options))
    end

    # Retrieves a list of all actions from the server.
    def get_actions(options={})
      return send_message(SkyDB::Message::GetActions.new(options))
    end


    ####################################
    # Property Messages
    ####################################

    # Adds a property to the server.
    #
    # @param [Property] property  the property to add.
    def add_property(property, options={})
      return send_message(SkyDB::Message::AddProperty.new(property, options))
    end

    # Retrieves an individual property from the server.
    #
    # @param [Fixnum] property_id  the identifier of the property to retrieve.
    def get_property(property_id, options={})
      return send_message(SkyDB::Message::GetProperty.new(property_id, options))
    end

    # Retrieves a list of all properties from the server.
    def get_properties(options={})
      return send_message(SkyDB::Message::GetProperties.new(options))
    end


    ####################################
    # Event Messages
    ####################################

    # Adds an event to the server.
    #
    # @param [Event] event  the event to add.
    def add_event(event, options={})
      return send_message(SkyDB::Message::AddEvent.new(event, options))
    end


    ####################################
    # Path Messages
    ####################################

    # Finds a count of the action that occurs immediately after a set of
    # actions.
    #
    # @param [Array] prior_action_ids  the prior action ids to match on.
    def next_actions(prior_action_ids, options={})
      return send_message(SkyDB::Message::NextActions.new(prior_action_ids, options))
    end

    ####################################
    # Multi message
    ####################################

    # Executes multiple messages in one call.
    def multi(options={})
      raise "Already in a multi-message block" unless @multi_message.nil?
      
      # Create multi-message.
      @multi_message = SkyDB::Message::Multi.new(options)
      
      # Execute the block normally and send the message.
      begin
        yield
        
        # Clear multi message so it doesn't add to itself.
        tmp = @multi_message
        @multi_message = nil
        
        # Send all messages at once.
        send_message(tmp)

      ensure
        @multi_message = nil
      end
      
      return nil
    end
    

    ####################################
    # Send
    ####################################

    # Sends a message to the server.
    #
    # @param [SkyDB::Message] message  the message to send.
    # @return [Object]  the object returned by the server.
    def send_message(message)
      # Set the table if they're not set.
      message.table = table if message.table.nil? || message.table.empty?

      # Validate message before sending.
      message.validate!
      
      # If this is part of a multi message then simply append the message for
      # later sending.
      if !@multi_message.nil?
        @multi_message.messages << message
        return nil
      
      # Otherwise send the message immediately.
      else
        # Connect to the server.
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
      
        # Close socket.
        socket.close()
      
        # TODO: Exception processing.
      
        # Process response back through the message.
        response = message.process_response(response)
      
        # Return response.
        return response
      end
    end
  end
end