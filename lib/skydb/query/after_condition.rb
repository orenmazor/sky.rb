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
        self.within = options[:within]
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################
      
      attr_accessor :within
      

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
        within_unit = (within.nil? ? nil : within[:unit])
        
        # Find the matching event and then move to the next one for selection.
        body << "if cursor:eos() or cursor:eof() then return false end"
        body << "remaining = #{within[:quantity].to_i}" if within_unit == 'step'
        body << "repeat"
        body << "  if remaining <= 0 then return false end" if within_unit == 'step'
        body << "  if cursor.event.action_id == #{action.id.to_i} then"
        body << "    cursor:next()"
        body << "    return true"
        body << "  end"
        body << "  remaining = remaining - 1" if within_unit == 'step'
        body << "until not cursor:next()"
        body << "return false"

        # Indent body and return.
        body.map! {|line| "  " + line}
        return header + body.join("\n") + "\n" + footer
      end


      ####################################
      # Serialization
      ####################################
    
      # Serializes the condition into a hash.
      def to_hash(*a)
        json = super(*a)
        json['within'] = within.to_hash(*a) unless within.nil?
        json
      end

      # Deserializes the condition from a hash.
      def from_hash(hash, *a)
        super(hash, *a)
        return nil if hash.nil?
        
        hash['within']._symbolize_keys! unless hash['within'].nil?
        self.within = hash['within']

        return self
      end
    end
  end
end

