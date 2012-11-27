class SkyDB
  class Message
    class Lua
      class MapReduce < SkyDB::Message
        ########################################################################
        #
        # Constructor
        #
        ########################################################################

        # Initializes the 'lua::map_reduce' message.
        #
        # @param [String] source  the Lua source to execute.
        def initialize(source=nil, options={})
          super('lua::map_reduce')
          self.source = source
        end


        ##########################################################################
        #
        # Attributes
        #
        ##########################################################################

        ##################################
        # Source
        ##################################

        # The Lua source code.
        attr_reader :source
      
        def source=(value)
          @source = value.to_s
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
            :source => source
          }.to_msgpack
        end
      end
    end
  end
end