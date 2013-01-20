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
        self.action_id = options[:action_id]
        self.function_name = options[:function_name]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The function name to use when generating the code.
      attr_accessor :function_name

      # The name of the action to match. This is a placeholder so that the
      # query can automatically lookup the action identifier and set it on
      # the action_id property before codegen.
      attr_accessor :action

      # The name of the action identifier to match.
      attr_accessor :action_id


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
        if !(action_id.to_i > 0)
          raise SkyDB::Query::ValidationError.new("Action identifier required and must be greater than zero for #{self.inspect}.")
        end

        # Require the function name. This should be set automatically by the
        # query.
        if function_name.to_s.index(/^\w+$/).nil?
          raise SkyDB::Query::ValidationError.new("Invalid function name '#{function_name.to_s}' for #{self.inspect}.")
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
        if options[:next]
          body << "while cursor:next() do"
        else
          body << "repeat"
        end

        body << "  if cursor.event.action_id == #{action_id} then"
        body << "    return true"
        body << "  end"

        if options[:next]
          body << "end"
        else
          body << "until not cursor:next()"
        end

        body << "return false"

        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end
    end
  end
end

