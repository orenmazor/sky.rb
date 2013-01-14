class SkyDB
  class Message
    class DeleteTable < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'delete table' message.
      #
      # @param [Table] table  the table to delete.
      def initialize(table=nil, options={})
        super('delete_table')
        self.table = table
      end


      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      ##################################
      # Table
      ##################################

      # The talbe to add.
      attr_reader :table
      
      def table=(value)
        @table = value.is_a?(Table) ? value : nil
      end


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################

      ##################################
      # Validation
      ##################################

      # A flag stating if the table is required for this type of message.
      def require_table?
        return false
      end

      ####################################
      # Encoding
      ####################################

      # Encodes the message body.
      #
      # @param [IO] buffer  the buffer to write the header to.
      def encode_body(buffer)
        buffer << {
          name: table.name
        }.to_msgpack
      end
    end
  end
end