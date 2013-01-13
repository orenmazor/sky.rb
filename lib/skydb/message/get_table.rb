class SkyDB
  class Message
    class GetTable < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'get_table' message.
      #
      # @param [Fixnum] name  the name of the table to retrieve.
      def initialize(name=nil, options={})
        super('get_table')
        self.name = name
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Name
      ##################################

      # The name of the table to retrieve.
      attr_reader :name
      
      def name=(value)
        @name = value.to_s
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
        buffer << {
          name: name
        }.to_msgpack
      end

      def process_response(response)
        if !response.nil?
          response = SkyDB::Table.new(response['name'])
        end
        return response
      end
    end
  end
end