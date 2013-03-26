require 'net/http'
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


    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the client.
    def initialize(options={})
      self.host = options[:host] || DEFAULT_HOST
      self.port = options[:port] || DEFAULT_PORT
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


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Table API
    ####################################

    # Creates a table on the server.
    #
    # @param [Table] table  the table to create.
    def create_table(table, options={})
      raise ArgumentError.new("Table required") if table.nil?
      data = send(:post, "/tables", table.to_hash)
      return table.from_hash(data)
    end

    # Deletes a table on the server.
    #
    # @param [Table] table  the table to delete.
    def delete_table(table, options={})
      raise ArgumentError.new("Table required") if table.nil?
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

    # Creates a property on a table.
    #
    # @param [Property] property  the property to create.
    def create_property(table, property, options={})
      raise ArgumentError.new("Table required") if table.nil?
      raise ArgumentError.new("Property required") if table.nil?
      data = send(:post, "/tables/#{table.name}/properties", property.to_hash)
      return property.from_hash(data)
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
      request.body = JSON.generate(data) unless data.nil?
      response = Net::HTTP.new(host, port).start {|http| http.request(request) }
      
      # Parse the body as JSON.
      json = JSON.parse(response.body) rescue nil
      message = json['message'] rescue nil
      
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