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
      @multi_message_max_count = 0
      
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

    # The name of the table to connect to.
    attr_accessor :table_name


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Table Messages
    ####################################

    # Creates a table on the server.
    #
    # @param [Table] table  the table to add.
    def create_table(table, options={})
      return send_message(SkyDB::Message::CreateTable.new(table, options))
    end

    # Deletes a table on the server.
    #
    # @param [Table] table  the table to delete.
    def delete_table(table, options={})
      return send_message(SkyDB::Message::DeleteTable.new(table, options))
    end

    # Retrieves an individual table from the server, if it exists. Otherwise
    # returns nil.
    #
    # @param [Fixnum] action_id  the identifier of the action to retrieve.
    def get_table(action_id, options={})
      return send_message(SkyDB::Message::GetTable.new(action_id, options))
    end


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
    # Utility message
    ####################################

    # Checks if the server is up and running.
    #
    # @returns [Boolean]  a flag stating if the server is running.
    def ping(options={})
      begin
        send_message(SkyDB::Message::Ping.new(options))
        return true
      rescue
        return false
      end
    end

    # Looks up lists of actions and properties by name.
    def lookup(options={})
      send_message(SkyDB::Message::Lookup.new(options))
      return nil
    end


    ####################################
    # Lua Messages
    ####################################

    # Executes a Lua aggregation job on the server and returns the results.
    #
    # @param [String] source  the Lua source code to execute
    def aggregate(source, options={})
      return send_message(SkyDB::Message::Lua::Aggregate.new(source, options))
    end


    ####################################
    # Query Interface
    ####################################

    # Starts a query against the database.
    #
    # @param [String] selection  a list of properties to select from the database.
    def select(fields)
      return SkyDB::Query.new(:client => self).select(fields)
    end


    ####################################
    # Multi message
    ####################################

    # Executes multiple messages in one call.
    def multi(options={})
      raise "Already in a multi-message block" unless @multi_message.nil?
      
      # Create multi-message.
      @multi_message = SkyDB::Message::Multi.new(options)
      @multi_message_max_count = options[:max_count].to_i
      
      # Execute the block normally and send the message.
      begin
        yield
        
        # Send all messages at once.
        if @multi_message.messages.length > 0
          send_message(@multi_message)
        end

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
      message.table_name = table_name if message.table_name.nil? || message.table_name.empty?

      # Validate message before sending.
      message.validate!
      
      # If this is part of a multi message then simply append the message for
      # later sending.
      if !@multi_message.nil? && @multi_message != message
        @multi_message.messages << message
        
        # Send off the MULTI if the message count is above our limit.
        if @multi_message_max_count > 0 && @multi_message.messages.length >= @multi_message_max_count
          send_message(@multi_message)
          @multi_message = SkyDB::Message::Multi.new()
        end
        
        return nil
      
      # Otherwise send the message immediately.
      else
        begin
          # Connect to the server.
          socket = TCPSocket.new(host, port.to_i)
      
          # Encode and send message request.
          message.encode(socket)
      
          # Retrieve the respose as a buffer so we can inspect it.
          #msg, x = *socket.recvmsg
          #buffer = StringIO.new(msg)
          #puts "[#{message.message_name}]< #{buffer.string.to_hex}" if SkyDB.debug
      
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

        ensure
          # Make sure we remove the multi-message if that's what we're sending.
          @multi_message = nil if @multi_message == message
        end
      end
    end
  end
end