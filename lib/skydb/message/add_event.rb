class SkyDB
  class Message
    class AddEvent < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'event add' message.
      #
      # @param [Event] event  the event to add.
      def initialize(event=nil, options={})
        super('add_event')
        self.event = event
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Event
      ##################################

      # The event to add.
      attr_reader :event
      
      def event=(value)
        @event = value if value.is_a?(Event)
      end


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################

      ####################################
      # Validation
      ####################################

      def validate!
        super
        
        if !(event.object_id > 0)
          raise SkyDB::ObjectIdRequiredError.new('Object ID required')
        end
        
        if event.timestamp.nil?
          raise SkyDB::TimestampRequiredError.new('Timestamp required')
        end
      end


      ####################################
      # Encoding
      ####################################

      # Encodes the message body.
      #
      # @param [IO] buffer  the buffer to write the header to.
      def encode_body(buffer)
        buffer << event.to_msgpack
      end
    end
  end
end