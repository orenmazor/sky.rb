class SkyDB
  class Message
    class EADD < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'event add' message.
      #
      # @param [Event] event  the event to add.
      def initialize(event=nil, options={})
        super('eadd')
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