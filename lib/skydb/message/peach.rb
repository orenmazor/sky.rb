class SkyDB
  class Message
    class PEACH < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'path each' message.
      #
      # @param [String] query  the query to execute.
      def initialize(query=nil, options={})
        super(Type::PEACH)
        self.query = query
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Query
      ##################################

      # The query to execute over each path.
      attr_reader :query
      
      def query=(value)
        @query = value.to_s
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
        buffer << query.to_msgpack
      end
    end
  end
end