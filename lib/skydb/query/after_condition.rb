class SkyDB
  class Query
    # The 'after' condition filters out selection only after the condition
    # has been fulfilled.
    class AfterCondition < SkyDB::Query::Condition
      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      def initialize(action=nil, options={})
        options.merge!(action.is_a?(Hash) ? action : {:action => action})
        super(options)
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
        # Do not allow the :enter action. That is reserved for the 'On'
        # condition.
        if action == :enter
          raise SkyDB::Query::ValidationError.new("Enter actions cannot be used with an 'after' condition. Please use an 'on' condition instead.")
        end

        super
        
        return nil
      end


      ##################################
      # Codegen
      ##################################

      # Generates Lua code to match a given action.
      def codegen(options={})
        header, body, footer = "function #{function_name.to_s}(cursor, data)\n", [], "end\n"
      
        # Find the matching event and then move to the next one for selection.
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

