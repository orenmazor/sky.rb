class SkyDB
  class Query
    # The Condition class is the base class for all query classes that limit
    # the selection.
    class Condition
      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      def initialize(options={})
        self.action = options[:action]
        self.function_name = options[:function_name]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The function name to use when generating the code.
      attr_accessor :function_name

      # The action to match. If set to a string or id then it is automatically
      # wrapped in an Action object.
      attr_reader :action
      
      def action=(value)
        if value.is_a?(Symbol)
          @action = :enter
        elsif value.is_a?(String)
          @action = SkyDB::Action.new(:name => value)
        elsif value.is_a?(Fixnum)
          @action = SkyDB::Action.new(:id => value)
        elsif value.is_a?(SkyDB::Action)
          @action = value
        else
          @action = nil
        end
      end


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################

      ##################################
      # Validation
      ##################################

      # Validates that the object is correct before executing a codegen.
      def validate!
        # Require the action identifier.
        if action.nil? || action == :enter || action.id.to_i == 0
          raise SkyDB::Query::ValidationError.new("Action with non-zero identifier required.")
        end

        # Require the function name. This should be set automatically by the
        # query.
        if function_name.to_s.index(/^\w+$/).nil?
          raise SkyDB::Query::ValidationError.new("Invalid function name '#{function_name.to_s}'.")
        end
        
        return nil
      end
      
      
      ##################################
      # Codegen
      ##################################

      # Generates Lua code to match a given action.
      def codegen(options={})
        return "function #{function_name.to_s}(cursor, data) return false end\n"
      end


      ####################################
      # Serialization
      ####################################
    
      # Serializes the condition into a JSON string.
      def to_json(*a); as_json.to_json(*a); end

      # Serializes the condition into a hash.
      def as_json(*a)
        json = {}
        json['type'] = self.class.to_s.split("::").last.gsub('Condition', '').downcase
        if action.is_a?(SkyDB::Action)
          json['action'] = action.as_json(*a)
        elsif action.is_a?(Symbol)
          json['action'] = action
        end
        json
      end
    end
  end
end

