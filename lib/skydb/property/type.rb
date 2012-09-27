class SkyDB
  class Property
    class Type
      ########################################################################
      #
      # Constants
      #
      ########################################################################

      OBJECT = 1

      ACTION = 2


      ########################################################################
      #
      # Static Methods
      #
      ########################################################################
      
      # Encodes the type into it's numeric enum value.
      #
      # @param type [Symbol]  the type.
      # @return [Fixnum]  the enum value for the property type.
      def self.encode(type)
        return nil unless [:object, :action].index(type)
        return type == :object ? OBJECT : ACTION
      end

      # Decodes the numeric enum value into its symbol.
      #
      # @param value [Fixnum]  the numeric enum value.
      # @return [Symbol]  the type symbol.
      def self.decode(value)
        return nil unless [OBJECT, ACTION].index(value)
        return value == OBJECT ? :object : :action
      end
    end
  end
end