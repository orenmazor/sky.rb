require 'skydb/query/selection'
require 'skydb/query/after_condition'
require 'skydb/query/validation_error'

class SkyDB
  # The Query object represents a high level abstraction of how data is
  # processed and retrieved from the database. It is inspired by ActiveRecord
  # in the sense that commands can be chained together.
  #
  # The query is not executed until the execute() method is called.
  class Query
    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    def initialize(options={})
      self.client = options[:client]
      self.selection = options[:selection] || SkyDB::Query::Selection.new()
      self.conditions = options[:conditions] || []
    end
    

    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The client that is used for executing the query.
    attr_accessor :client

    # The properties that should be selected from the database.
    attr_accessor :selection

    # A list of conditions that must be fulfilled before selection can occur.
    attr_accessor :conditions

    # The number of idle seconds that separates sessions. 
    attr_accessor :session_idle_time


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Helpers
    ####################################

    # Adds a list of fields to the selection.
    #
    # @param [String] fields  A list of fields to add to the selection.
    #
    # @return [Query]  The query object is returned.
    def select(*fields)
      selection.select(*fields)
      return self
    end

    # Adds one or more grouping fields to the selection of the query.
    #
    # @param [String] groups  A list of groups to add to the selection.
    #
    # @return [Query]  The query object is returned.
    def group_by(*groups)
      selection.group_by(*groups)
      return self
    end

    # Adds an 'after' condition to the query.
    #
    # @param [Hash] options  The options to pass to the 'after' condition.
    #
    # @return [Query]  The query object is returned.
    def after(options={})
      conditions << SkyDB::Query::AfterCondition.new(options)
      return self
    end

    # Sets the session idle seconds and returns the query object.
    #
    # @param [Fixnum] seconds  The number of idle seconds.
    #
    # @return [Query]  The query object is returned.
    def session(seconds)
      self.session_idle_time = seconds
      return self
    end


    ####################################
    # Execution
    ####################################

    # Executes the query and returns the resulting data.
    def execute
      # Generate the Lua code for this query.
      code = codegen()
      
      # Send it to the server.
      results = client.aggregate(code)
      
      # Return the results.
      return results
    end


    ####################################
    # Validation
    ####################################

    # Validates that all the elements of the query are valid.
    def validate!
      selection.validate!
    end
    
    
    ####################################
    # Codegen
    ####################################

    # Generates the Lua code that represents the query.
    def codegen
      # Lookup all actions & properties.
      lookup_identifiers()
      
      # Validate everything in query before proceeding.
      validate!

      # Generate selection.
      code = []
      code << selection.codegen_select()
      
      # Generate condition functions.
      conditions.each_with_index do |condition, index|
        condition.function_name ||= "__condition#{nextseq}"
        code << condition.codegen
      end

      # Generate the invocation of the conditions.
      conditionals = conditions.map {|condition| "#{condition.function_name}(cursor, data)"}.join(' and ')
      conditionals = "true" if conditions.length == 0
      
      # Generate aggregate() function.
      code << "function aggregate(cursor, data)"
      code << "  cursor:set_session_idle(#{session_idle_time.to_i})" if session_idle_time.to_i > 0
      code << "  while cursor:next_session() do"
      code << "    while cursor:next() do"
      code << "      if #{conditionals} then"
      code << "        select(cursor, data)"
      code << "      end"
      code << "    end"
      code << "  end"
      code << "end"
      code << ""

      # Generate merge function.
      code << selection.codegen_merge()
      
      return code.join("\n")
    end


    ####################################
    # Utility
    ####################################
    
    private
    
    # Generates a sequence number used for uniquely naming objects and
    # functions in the query.
    def nextseq
      @sequence = (@sequence || 0) + 1
    end

    # Looks up all actions and properties that are missing an identifier.
    def lookup_identifiers
      # Find all the actions on conditions that are missing an id.
      actions = []
      conditions.each do |condition|
        if condition.action.is_a?(SkyDB::Action) && condition.action.id.to_i == 0
          actions << condition.action
        end
      end

      # Lookup all the actions.
      if actions.length > 0
        client.lookup(:actions => actions)
      end
      
      return nil
    end
  end
end