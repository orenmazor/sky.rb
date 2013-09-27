require 'net/http'
require 'net/https'
require 'json'

class SkyDB
  class Client
    ##########################################################################
    #
    # Errors
    #
    ##########################################################################

    class ServerError < SkyError
      attr_accessor :status
    end

    
    
    ##########################################################################
    #
    # Constants
    #
    ##########################################################################

    # The default host to connect to if one is not specified.
    DEFAULT_HOST = 'localhost'

    # The default port to connect to if one is not specified.
    DEFAULT_PORT = 8585

    #use http by default
    USE_SSL = false

    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the client.
    def initialize(options={})
      self.host = options[:host] || DEFAULT_HOST
      self.port = options[:port] || DEFAULT_PORT
      self.ssl = options[:ssl] || USE_SSL
    end


    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The name of the host to conect to.
    attr_accessor :host

    # The port on the host to connect to.
    attr_accessor :port

    # Enable/Disable HTTPS
    attr_accessor :ssl


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Table API
    ####################################

    # Retrieves a list of tables on the server.
    def get_tables(options={})
      data = send(:get, "/tables")
      tables = data.map {|i| Table.new(:client => self).from_hash(i)}
      return tables
    end

    # Retrieves a single table from the server.
    def get_table(name, options={})
      raise ArgumentError.new("Table name required") if name.nil?
      data = send(:get, "/tables/#{name}")
      table = Table.new(:client => self).from_hash(data)
      return table
    end

    # Creates a table on the server.
    #
    # @param [Table] table  the table to create.
    def create_table(table, options={})
      raise ArgumentError.new("Table required") if table.nil?
      table = Table.new(table) if table.is_a?(Hash)
      table.client = self
      data = send(:post, "/tables", table.to_hash)
      return table.from_hash(data)
    end

    # Deletes a table on the server.
    #
    # @param [Table] table  the table to delete.
    def delete_table(table, options={})
      raise ArgumentError.new("Table required") if table.nil?
      table = Table.new(table) if table.is_a?(Hash)
      table.client = self
      send(:delete, "/tables/#{table.name}")
      return nil
    end


    ####################################
    # Property API
    ####################################

    # Retrieves a list of all properties on a table.
    #
    # @return [Array]  the list of properties on the table.
    def get_properties(table, options={})
      raise ArgumentError.new("Table required") if table.nil?
      properties = send(:get, "/tables/#{table.name}/properties")
      properties.map!{|p| Property.new().from_hash(p)}
      return properties
    end

    # Retrieves a single property by name.
    #
    # @param [Table] table  The table to retrieve from.
    # @param [String] name  The name of the property to retrieve.
    #
    # @return [Array]  the list of properties on the table.
    def get_property(table, name, options={})
      raise ArgumentError.new("Table required") if table.nil?
      data = send(:get, "/tables/#{table.name}/properties/#{name}")
      return Property.new().from_hash(data)
    end

    # Creates a property on a table.
    #
    # @param [Property] property  the property to create.
    def create_property(table, property, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Property required") if property.nil?
      property = Property.new(property) if property.is_a?(Hash)
      data = send(:post, "/tables/#{table.name}/properties", property.to_hash)
      return property.from_hash(data)
    end

    # Updates a property on a table.
    #
    # @param [Property] property  the property to update.
    def update_property(table, property, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Property required") if property.nil?
      raise ArgumentError.new("Property name required") if property.name.to_s == ''
      property = Property.new(property) if property.is_a?(Hash)
      data = send(:patch, "/tables/#{table.name}/properties/#{property.name}", property.to_hash)
      return property.from_hash(data)
    end

    # Deletes a property on a table.
    #
    # @param [Property] property  the property to delete.
    def delete_property(table, property, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Property required") if property.nil?
      raise ArgumentError.new("Property name required") if property.name.to_s == ''
      property = Property.new(property) if property.is_a?(Hash)
      send(:delete, "/tables/#{table.name}/properties/#{property.name}")
      return nil
    end


    ####################################
    # Event API
    ####################################

    # Retrieves all events for a given object.
    #
    # @return [Array]  the list of events on the table.
    def get_events(table, object_id, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Object identifier required") if object_id.nil?
      events = send(:get, "/tables/#{table.name}/objects/#{object_id}/events")
      events.map!{|e| Event.new().from_hash(e)}
      return events
    end

    # Retrieves the event that occurred at a given point in time for an object.
    #
    # @return [Event]  the event.
    def get_event(table, object_id, timestamp, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Object identifier required") if object_id.nil?
      raise ArgumentError.new("Timestamp required") if timestamp.nil?
      data = send(:get, "/tables/#{table.name}/objects/#{object_id}/events/#{SkyDB.format_timestamp(timestamp)}")
      return Event.new().from_hash(data)
    end

    # Adds an event to an object.
    #
    # @param [Table] table  the table the object belongs to.
    # @param [String] object_id  the object's identifier.
    # @param [Event] event  the event to add.
    #
    # @return [Event]  the event.
    def add_event(table, object_id, event, options={})
      options = {:method => :merge}.merge(options)
      
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Object identifier required") if object_id.nil?
      raise ArgumentError.new("Event required") if event.nil?
      event = Event.new(event) if event.is_a?(Hash)
      raise ArgumentError.new("Event timestamp required") if event.timestamp.nil?

      # The insertion method is communicated to the server through the HTTP method.
      http_method = case options[:method]
        when :replace then :put
        when :merge then :patch
        else raise ArgumentError.new("Invalid event insertion method: #{options[:method]}")
        end

      # Send the event and parse it when it comes back. It could have changed.
      data = send(http_method, "/tables/#{table.name}/objects/#{object_id}/events/#{SkyDB.format_timestamp(event.timestamp)}", event.to_hash)
      return event.from_hash(data)
    end

    # Deletes an event for an object on a table.
    #
    # @param [Table] table  the table the object belongs to.
    # @param [String] object_id  the object's identifier.
    # @param [Event] event  the event to delete.
    def delete_event(table, object_id, event, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Object identifier required") if object_id.nil?
      raise ArgumentError.new("Event required") if event.nil?
      event = Event.new(event) if event.is_a?(Hash)
      raise ArgumentError.new("Event timestamp required") if event.timestamp.nil?
      send(:delete, "/tables/#{table.name}/objects/#{object_id}/events/#{SkyDB.format_timestamp(event.timestamp)}")
      return nil
    end


    ####################################
    # Query API
    ####################################

    # Runs a query against a given table.
    #
    # @param [Table] table  The table to query.
    # @param [Hash] q  The query definition to run.
    #
    # @return [Results]  the results of the query.
    def query(table, q)
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Query definition required") if q.nil?
      q = {:statements => q} if q.is_a?(Array)
      return send(:post, "/tables/#{table.name}/query", q)
    end


    ####################################
    # Utility API
    ####################################

    # Pings the server to determine if it is running.
    #
    # @return [Boolean]  true if the server is running, otherwise false.
    def ping(options={})
      begin
        send(:get, "/ping")
      rescue
        return false
      end
      return true
    end


    ####################################
    # HTTP Utilities
    ####################################
    
    # Executes a RESTful JSON over HTTP POST.
    def send(method, path, data=nil)
      # Generate a JSON request.
      request = case method
        when :get then Net::HTTP::Get.new(path)
        when :post then Net::HTTP::Post.new(path)
        when :patch then Net::HTTP::Patch.new(path)
        when :put then Net::HTTP::Put.new(path)
        when :delete then Net::HTTP::Delete.new(path)
        end
      request.add_field('Content-Type', 'application/json')
      request.body = JSON.generate(data, :max_nesting => 200) unless data.nil?

      http = Net::HTTP.new(host, port)
      if ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE #BAD
      end

      response = http.start {|h| h.request(request) }
      
      # Parse the body as JSON.
      json = JSON.parse(response.body) rescue nil
      message = json['message'] rescue nil
      
      warn("#{method.to_s.upcase} #{path}: #{request.body} -> #{response.body}") if SkyDB.debug

      # Process based on the response code.
      case response
      when Net::HTTPSuccess then
        return json
      else
        e = ServerError.new(message)
        e.status = response.code
        raise e
      end
    end
  end
end