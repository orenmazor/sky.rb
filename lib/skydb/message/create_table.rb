class SkyDB
  class Message
    class CreateTable < SkyDB::Message
      ########################################################################
      #
      # Constructor
      #
      ########################################################################

      # Initializes the 'create table' message.
      #
      # @param [Table] table  the table to create.
      def initialize(table=nil, options={})
        super('create_table')
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

      ####################################
      # Encoding
      ####################################

      # Encodes the message body.
      #
      # @param [IO] buffer  the buffer to write the header to.
      def encode_body(buffer)
        puts "BODY"
        buffer << table.to_msgpack
      end
    end
  end
end