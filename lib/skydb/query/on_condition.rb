class SkyDB
  class Query
    # The 'on' condition filters a selection and leaves the cursor on the
    # current matching event.
    class OnCondition < SkyDB::Query::Condition
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
      # Codegen
      ##################################

      # Generates Lua code to match a given action.
      def codegen(options={})
        header, body, footer = "function #{function_name.to_s}(cursor, data)\n", [], "end\n"
      
        # If the action is :enter then just check for the beginning of a session.
        if action == :enter
          body << "return (cursor.session_event_index == 0)"
        else
          # Only move to the next event if directed to by the options.
          body << "if cursor:eos() or cursor:eof() then return false end"
          body << "repeat"
          body << "  if cursor.event.action_id == #{action.id.to_i} then"
          body << "    return true"
          body << "  end"
          body << "until not cursor:next()"
          body << "return false"
        end

        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end
    end
  end
end

