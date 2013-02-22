require 'yaml'
require 'csv'
require 'yajl'
require 'zlib'
require 'bzip2'
require 'open-uri'
require 'ruby-progressbar'
require 'apachelogregex'
require 'useragent'

class SkyDB
  class Import
    class Importer
      ##########################################################################
      #
      # Errors
      #
      ##########################################################################

      class UnsupportedFileType < StandardError; end
      class TransformNotFound < StandardError; end
      

      ##########################################################################
      #
      # Constructor
      #
      ##########################################################################

      # Initializes the importer.
      def initialize(options={})
        @translators = []

        self.client = options[:client] || SkyDB.client
        self.table_name  = options[:table_name]
        self.format = options[:format]
        self.files  = options[:files] || []
      end
    

      ##########################################################################
      #
      # Attributes
      #
      ##########################################################################

      # The client to access the Sky server with.
      attr_accessor :client

      # The name of the table to import into.
      attr_accessor :table_name

      # The format file to use for translating the input data.
      attr_accessor :format

      # A list of translators to use to convert input rows into output rows.
      attr_reader :translators

      # A list of files to input from.
      attr_accessor :files

      # A list of header names to use for CSV files. Using this option will
      # treat the CSV input as not having a header row.
      attr_accessor :headers

      # The file type of file being imported can be one of
      # :csv, :tsv, :json, :apache_log
      attr_accessor :file_type


      ##########################################################################
      #
      # Methods
      #
      ##########################################################################
    
      ##################################
      # Import
      ##################################
    
      # Imports records from a list of files.
      #
      # @param [Array]  a list of files to import.
      def import(files, options={})
        files = [files] unless files.is_a?(Array)
        options[:progress_bar] = true unless options.has_key?(:progress_bar)
        progress_bar = nil
        
        # Set the table to import into.
        SkyDB.table_name = table_name

        # Initialize progress bar.
        count = files.inject(0) do |cnt,file|
          # disable progress bar if using compressed files
          if Dir.glob(file).detect{|f|['.gz','.bz2'].include?(File.extname(f).downcase)}
            options[:progress_bar] = false
            break
          end
          cnt + %x{wc -l #{file}|tail -1}.split.first.to_i
        end

        progress_bar = ::ProgressBar.create(:total => count, :format => '|%B| %P%%') if options[:progress_bar]

        # Loop over each of the files.
        files_expanded = files.inject([]) {|fs,fg| fs.concat(Dir[File.expand_path(fg)].delete_if{|f| File.directory?(f)}); fs}
        SkyDB.multi(:max_count => 1000) do
          files_expanded.each do |file|
            each_record(file, options) do |input|
              # Convert input line to a symbolized hash.
              output = translate(input)
              output._symbolize_keys!
              
              # p output

              if output[:object_id].nil?
                progress_bar.clear() unless progress_bar.nil?
                $stderr.puts "[ERROR] Object id required on line #{$.}"
              elsif output[:timestamp].nil?
                progress_bar.clear() unless progress_bar.nil?
                $stderr.puts "[ERROR] Invalid timestamp on line #{$.}"
              else
                # Convert hash to an event and send to Sky.
                event = SkyDB::Event.new(output)
                SkyDB.add_event(event)
              end
            
              # Update progress bar.
              progress_bar.increment() unless progress_bar.nil?
            end
          end
        end

        # Finish progress bar.
        progress_bar.finish() unless progress_bar.nil? || progress_bar.finished?
        
        return nil
      end


      ##################################
      # File Iteration
      ##################################
    
      def file_foreach(file, &block)
        case File.extname(file).downcase
        when '.bz2'
          Bzip2::Reader.foreach(file) do |line|
            yield line
          end
        when '.gz'
          Zlib::GzipReader.open(file) do |f|
            f.each_line(file) do |line|
              yield line
            end
          end
        else
          File.foreach(file) do |line|
            yield line
          end
        end
      end


      ##################################
      # Iteration
      ##################################
    
      # Executes a block for each record in a given file. A record is defined
      # by the file's type (:csv, :tsv, :json).
      #
      # @param [String] file  the path to the file to iterate over.
      def each_record(file, options)
        # Determine file type automatically if not passed in.
        if self.file_type.nil?
          self.file_type = 
            case File.extname(file)
            when '.tsv' then :tsv
            when '.txt' then :tsv
            when '.json' then :json
            when '.csv' then :csv
            when '.log' then :apache_log
            end
          warn("[import] Determining file type: #{self.file_type || '???'}")
        end
        
        # Process the record by file type.
        case self.file_type
        when :csv then each_text_record(file, ",", options, &Proc.new)
        when :tsv then each_text_record(file, "\t", options, &Proc.new)
        when :json then each_json_record(file, options, &Proc.new)
        when :apache_log then each_apache_log_record(file, options, &Proc.new)
        else raise SkyDB::Import::Importer::UnsupportedFileType.new("File type not supported by importer: #{file_type || File.extname(file)}")
        end
        
        return nil
      end
      
      # Executes a block for each line of a delimited flat file format
      # (CSV, TSV).
      #
      # @param [String] file  the path to the file to iterate over.
      # @param [String] col_sep  the column separator.
      def each_text_record(file, col_sep, options)
        # Process each line of the CSV file.
        CSV.foreach(file, :headers => headers.nil?, :col_sep => col_sep) do |row|
          record = nil
          
          # If headers were not specified then use the ones from the
          # CSV file and just convert the row to a hash.
          if headers.nil?
            record = row.to_hash
          
          # If headers were specified then manually convert the row
          # using the headers provided.
          else
            record = {}
            headers.each_with_index do |header, index|
              record[header] = row[index]
            end
          end

          # Skip over blank rows.
          next if record.values.reject{|v| v == '' || v.nil? }.length == 0

          yield(record)
        end
      end

      # Executes a block for each line of a JSON file.
      #
      # @param [String] file  the path to the file to iterate over.
      def each_json_record(file, options)
        io = open(file)

        # Process each line of the JSON file.
        Yajl::Parser.parse(io) do |record|
          yield(record)
        end
      end

      # Executes a block for each line of a standard Apache log file.
      #
      # @param [String] file  the path to the file to iterate over.
      def each_apache_log_record(file, options)
        format = options[:format] || '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
        parser = ApacheLogRegex.new(format)

        file_foreach(file) do |line|
          begin
            hash = parser.parse!(line)
            m, method, url = *hash['%r'].to_s.match(/^(\w+) ([^ ]+)/)
            uri = URI.parse("http://localhost#{path}") rescue nil
            record = {
              :ip_address => hash['%h'],
              :timestamp => DateTime.strptime(hash['%t'].gsub(/\[|\]/, ''), "%d/%b/%Y:%H:%M:%S %z"),
              :method => method,
              :url => url,
              :status_code => hash['%s'],
              :size => hash['%b'],
            }
            record[:user_identifier] = hash['%l'] unless hash['%l'] == '-'
            record[:user_id] = hash['%u'] unless hash['%u'] == '-'

            # Extract the parts of the URI.
            if !uri.nil?
              record[:path] = uri.path
              record[:query_string] = uri.query
              record[:query] = CGI::parse(uri.query) rescue {}
              record[:fragment] = uri.fragment
            end

            # Extract the referrer if there is one.
            if !hash['%{Referer}i'].nil? && hash['%{Referer}i'] != '-'
              record[:referer] = hash['%{Referer}i']
              referer_uri = URI.parse(record[:referer]) rescue nil
              if !referer_uri.nil?
                record[:referer_host] = referer_uri.host
                record[:referer_path] = referer_uri.path
                record[:referer_query_string] = referer_uri.query
                record[:referer_query] = CGI::parse(referer_uri.query) rescue {}
              end
            end
            
            # Extract specific user agent information.
            if !hash['%{User-Agent}i'].nil?
              user_agent = UserAgent.parse(hash['%{User-Agent}i'])
              record[:user_agent] = hash['%{User-Agent}i']
              record[:ua_name] = user_agent.browser.to_s unless user_agent.browser.nil?
              record[:ua_version] = user_agent.version.to_s unless user_agent.version.nil?
              record[:ua_platform] = user_agent.platform.to_s unless user_agent.platform.nil?
              record[:ua_os] = user_agent.os.to_s unless user_agent.os.nil?
              record[:ua_mobile] = user_agent.mobile?
            end

            # Skip junk log entries.
            next if method == "HEAD" || method == "OPTIONS"

            yield(record)

          rescue ApacheLogRegex::ParseError => e
            $stderr.puts "[ERROR] Unable to parse line #{$.} in #{file} (#{e.message})"
          end
        end
      end


      ##################################
      # Translation
      ##################################

      # Translates an input hash into an output hash using the translators.
      #
      # @param [Hash]  the input hash.
      #
      # @return [Hash]  the output hash.
      def translate(input)
        output = {:action => {}, :data => {}}

        translators.each do |translator|
          translator.translate(input, output)
        end

        output.delete(:action) if output[:action].keys.length == 0
        output.delete(:data) if output[:data].keys.length == 0
        return output
      end
      
      
      ##################################
      # Transform Management
      ##################################
    
      # Parses and appends the contents of a transform file to the importer.
      #
      # @param [String]  the YAML formatted transform file.
      def load_transform(content)
        # Parse the transform file.
        transform = {'fields' => {}}.merge(YAML.load(content))

        # Load any libraries requested by the format file.
        if transform['require'].is_a?(Array)
          transform['require'].each do |library_name|
            require library_name
          end
        end

        # Load individual field translations.
        load_transform_fields(transform['fields'])
        
        # Load a free-form translate function if specified.
        if !transform['translate'].nil?
          @translators << Translator.new(
            :translate_function => transform['translate']
          )
        end
        
        return nil
      end

      # Loads a hash of transforms.
      #
      # @param [Hash]  the hash of transform info.
      # @param [Array]  the path of fields.
      def load_transform_fields(fields, path=nil)
        # Convert each field to a translator.
        fields.each_pair do |key, value|
          translator = Translator.new(:output_field => (path.nil? ? key : path.clone.concat([key])))

          # Load a regular transform.
          if value.is_a?(String)
            # If the line is wrapped in curly braces then generate a translate function.
            m, code = *value.match(/^\s*\{(.*)\}\s*$/)
            if !m.nil?
              translator.translate_function = code
          
            # Otherwise it's a colon-separated field describing the input field and data type.
            else
              input_field, format = *value.strip.split(":")
              translator.input_field = input_field
              translator.format = format
            end

          # If this field is a hash then load it as a nested transform.
          elsif value.is_a?(Hash)
            load_transform_fields(value, path.to_a.clone.flatten.concat([key]))
          
          else
            raise "Invalid data type for '#{key}' in transform file: #{value.class}"
          end
          
          # Append to the list of translators.
          @translators << translator
        end
      end


      # Parses and appends the contents of a transform file to the importer.
      #
      # @param [String]  the filename to load from.
      def load_transform_file(filename)
        transforms_path = File.expand_path(File.join(File.dirname(__FILE__), 'transforms'))
        named_transform_path = File.join(transforms_path, "#{filename}.yml")
        
        # If it's just a word then find it in the gem.
        if filename.index(/^\w+$/)
          raise TransformNotFound.new("Named transform not available: #{filename} (#{named_transform_path})") unless File.exists?(named_transform_path)
          return load_transform(IO.read(named_transform_path))

        # Otherwise load it from the present working directory.
        else
          raise TransformNotFound.new("Transform file not found: #{filename}") unless File.exists?(filename)
          return load_transform(IO.read(filename))
        end
      end
    end
  end
end