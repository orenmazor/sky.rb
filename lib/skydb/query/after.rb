class SkyDB
  class Query
    # The 'after' condition filters out selection only after the condition
    # has been fulfilled.
    class After
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
        if value.is_a?(String)
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
        if action.nil? || action.id.to_i == 0
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
        header, body, footer = "function #{function_name.to_s}(cursor, data)\n", [], "end\n"
      
        # Only move to the next event if directed to by the options.
        body << "repeat"
        body << "  if cursor.event.action_id == #{action.id.to_i} then"
        body << "    cursor:next()"
        body << "    return true"
        body << "  end"
        body << "until not cursor:next()"

        body << "return false"

        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end
    end
  end
end

