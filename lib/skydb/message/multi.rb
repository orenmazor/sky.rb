class SkyDB
  class Message
    class Multi < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'multi' message.
      def initialize(options={})
        super('multi')
        self.messages = []
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Messages
      ##################################

      # A list of message to send to the server.
      attr_accessor :messages


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
      # @param [IO] buffer  the buffer to write to.
      def encode_body(buffer)
        # Encode the message count.
        buffer << {
          :count => messages.length
        }.to_msgpack
        
        # Encode all the messages.
        messages.each do |message|
          message.encode(buffer)
        end
      end
    end
  end
end