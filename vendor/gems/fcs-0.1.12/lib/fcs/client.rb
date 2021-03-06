

module FinalCutServer
  
  # 
  # The Client class provides the means by which the FCS library interacts with Final Cut Server,
  # utilizing the +fcsvr_client+ command-line tool.
  #
  class Client
    
    #
    # A custom exception thrown when a command times out.
    #
    class ClientTimeout < RuntimeError
      attr_reader :command, :bytes_read
      
      def initialize(command = nil, bytes_read = nil)
        @command = command
        @bytes_read = bytes_read
      end
    end
    
    # We're going to use 'clone' as an autogenerated method, so remove the standard
    # clone method first
    undef_method :clone
    
    # Add accessor methods for a couple of class variables
    class << self
      attr_accessor :fcs_binary, :fcs_timeout, :ssh_host, :ssh_username, :ssh_private_key_file
    end
    
    # Default values
    self.fcs_binary  = "/Library/Application\\ Support/Final\\ Cut\\ Server/Final\\ Cut\\ Server.bundle/Contents/MacOS/fcsvr_client"
    self.fcs_timeout = 30
    self.ssh_host = "Cook.local"
    self.ssh_username = "shouser"
    self.ssh_private_key_file = "~/.ssh/id_rsa"
    
    # find out how many bytes were read during the last command.
    attr_accessor :bytes_read, :last_call, :last_search_xml, :last_raw_response
    
    def initialize
      self.bytes_read = 0
      self.last_call = ""
      self.last_search_xml = ""
      self.last_raw_response = ""
    end
    
    # Overridden to turn +client.something(options, arg1, arg2)+ into a call to
    # +client.run('something', options, [arg1, arg2])+. See run() for details.
    def method_missing(cmd, options = {}, *args)
      run(cmd, options, *args)
    end
    
    protected
    
    #
    # Run the given fcsvr_client command with the specified arguments and return
    # the result as a String.
    #
    # - cmd:      The fcsvr_client command to run.
    # - options:  An optional Hash of Ruby-style options, to be converted into 
    #             command-line options.
    # - args:     An optional list of general arguments, to be appended to the 
    #             command-line invocation.
    #
    # Returns String.
    #
    # ==== Examples
    #   client.list_groups({:maxcount => 10}, "--xml")
    #   client.getmd({}, '/asset/352')
    #   client.list_parent_links({:xml => true}, '/asset/352')
    #
    def run(cmd, options, args = [])
      puts cmd
      # If the options contain a :sudo option, remove it record it's value for use in the call.
      sudo = options.delete(:sudo)
      # if sudo isn't defined then it's assumed to be false
      if sudo.nil?
        sudo = ""
      else
        sudo = 'sudo'
      end
      
      xmlcrit = options.delete(:xmlcrit)
      
      args = [args] if !args.empty? and args.kind_of? String
      
      # If the options contain a :search_hash option, remove it and record it.
      search_hash = options.delete(:search_hash)
      #Convert the search hash to a xml search if it's found
      search_xml = create_search_xml(search_hash) unless search_hash.nil?
      
      # If the options contain a :xmlmd_hash option remove it and record it.
      xmlmd_hash = options.delete(:xmlmd_hash)
      # Convert the xmlmd hash into an xml for use in setting md on an object
      setmd_xml = FinalCutServer::FCSEntity.hash_to_md_xml(xmlmd_hash) unless xmlmd_hash.nil?
      puts setmd_xml if FinalCutServer.debug

      # If the options contain a :create_asset_xml option remove it and record it.
      create_asset_json = options.delete(:create_asset_json)
      # Convert the create_asset_json into a create asset xml that fits FCSvr format.
      create_asset_xml = FinalCutServer::Asset.convert_asset_with_reps_json_to_xml create_asset_json unless create_asset_json.nil?

      puts create_asset_xml if FinalCutServer.debug
      
      if xmlcrit.nil?
        xmlcrit = ""
      else
        xmlcrit = "--xmlcrit" 
      end
      # pull out some properly formatted (and applicable) options from the option hash
      opt_args = transform_options(options)
      # single-quote any arguments which aren't the 'end of argument list' marker (--)
      ext_args = args.map { |a| a == '--' ? a : "#{a}" }
      
      # build the call and print it if debugging
      call = "#{sudo.to_s} #{Client.fcs_binary} #{cmd.to_s} #{xmlcrit} #{(opt_args + ext_args).join(' ')}"
      puts call if FinalCutServer.debug or true
      
      # run the call via the command-line shell, printing the response in debug mode
      if search_xml.nil? and setmd_xml.nil? and create_asset_xml.nil?
        response = ssh_sh(call)
      elsif search_xml.nil? and setmd_xml.nil?
        response = ssh_sh(call, create_asset_xml)
      elsif setmd_xml.nil? and create_asset_xml.nil?
        response = ssh_sh(call, search_xml)
      elsif search_xml.nil? and create_asset_xml.nil?
        response = ssh_sh(call, setmd_xml)
      end
      
      puts response if FinalCutServer.debug
      
      # return the response
      response
    end

    public

    def create_asset_with_reps(asset_json)
      options = Hash.new
      options[:create_asset_json] = asset_json
      options[:sudo] = true
      options[:xml] = true

      created_asset_addr = create options, '/asset'
      return created_asset_addr
    end

    def create_asset(source_file_path, source_file_name, device_addr, description, keywords, project_addr, asset_type = "pa_asset_media", remove_original_file = true, trigger_analyze = true)
      return false if source_file_name.nil? || source_file_path.nil? || device_addr.nil?

      # instantiate and pull the file path for the device specified.   if it doesn't exist return false to indicate we couldn't create the asset
      dev = FinalCutServer::Device.new(self, [device_addr])
      dev.load_metadata
      dev_path = dev.metadata["DEV_ROOT_PATH_node"]["value"]

      # test to make sure that the directory and file specified exist
      file_full_path = File.expand_path source_file_name, source_file_path
      if remove_original_file == true
        return false unless test_remote_file file_full_path, '-w' and test_remote_file file_full_path, '-r'
      else
        return false unless test_remote_file file_full_path, '-r'
      end  

      # initalize the options hash
      options = Hash.new
      options[:background] = true
      options[:sudo] = true

      # check to see if the source_file_name exists already on the device specified.   if it does then add a _epochtime to the filename when it's copied
      counter_postfix = 0

      # break out pieces of the file for creating alternate file names as needed
      asset_extenstion = File.extname source_file_name
      asset_filename = File.basename source_file_name, asset_extenstion  

      # create the ultimate destination of the asset based on the device and source file
      asset_destination_full_path = File.expand_path asset_filename + asset_extenstion, dev_path
      asset_final_filename = source_file_name

      unless asset_destination_full_path == file_full_path
        while test_remote_file asset_destination_full_path, '-f'
          asset_final_filename = asset_filename + "_#{counter_postfix}" + asset_extenstion
          asset_destination_full_path = File.expand_path asset_final_filename, dev_path
          counter_postfix += 1
        end
        puts "Final filename determined to be #{asset_destination_full_path}" if FinalCutServer.debug
        ssh_sh "cp \"#{file_full_path}\" \"#{asset_destination_full_path}\" && chmod 644 \"#{asset_destination_full_path}\" && echo true || echo false"
      else
        puts "File and path specified are already within the destination device path.  No movement of file necessary" if FinalCutServer.debug
        asset_located_in_device = true
      end

      # if the project address is set then add the command line to add the asset to it when created
      options[:projaddr] = project_addr unless project_addr.nil? or project_addr.empty?

      # add the type of asset
      cmd = "#{asset_type} #{ERB::Util::url_encode(File.expand_path(asset_final_filename, device_addr)).gsub(/%2F/, "/")}"

      # if the description is not set then set it and append it during the creation call during the command line call
      description = asset_final_filename if description.nil? or description.empty?
      cmd += " CUST_DESCRIPTION=\"#{description}\"" 

      # if the keywords are set then set them during the command line call
      cmd += " CUST_KEYWORDS=\"#{keywords}\"" unless keywords.nil? or keywords.empty?

      # call the fcsvr_client with options and cmd
      asset_creation_response = createasset options, cmd

      # if we've gotten to this point and we were asked to remove the original file and the original file wasn't found to be already in the asset then do it!
      ssh_sh "rm \"#{file_full_path}\" \"#{file_full_path}_removed\"; echo true" unless asset_located_in_device == true or remove_original_file != true

      # if we were asked to analyze the asset after it's creation then let's do that using the asset address we received back from the creation call
      if trigger_analyze == true
        options = Hash.new
        options[:force] = true
        analyze options, asset_creation_response
      end

      # return back the asset address to indicate success and give the caller an id to refer to for further operations
      return asset_creation_response
    end

    # -f for file existance or -r for read access or -w for write access both test existance of file as part of their normal run.
    def test_remote_file(filename, access = '-r')
      puts "test #{access} \"#{filename}\" && echo true || echo false" if FinalCutServer.debug
      response = ssh_sh("test #{access} \"#{filename}\" && echo true || echo false")
      puts response if FinalCutServer.debug
      if response.chomp.eql? "true" then
        return true
      else
        return false
      end
    end

    #
    # Creates a properly formatted search xml string taking a hash of the correct form.
    # Primary purpose is to allow a json search ctieria string to be passed in and then
    # used for searching.
    #
    def create_search_xml(search_terms)
      @match_types = {"interesect" => {"id" => 3, "name" => "CRIT_INTERSECT"}, "value" => {"id" => 1, "name" => "CRIT_CMP_VALUE"}}

      raise "Search was malformed.   Empty!" if search_terms.nil?
      raise "Search was malformed.   No outer search." if search_terms["search"].nil?
      raise "Search was malformed.   No search type found!" if search_terms["search"]["type"].nil?
      raise "Search was malformed.   No criteria were specified" if search_terms["search"]["criteria"].nil? || search_terms["search"]["criteria"].empty?

      doc = REXML::Document.new "<session><values/></session>"

      doc << REXML::XMLDecl.new

      crit_type_value = REXML::Element.new "value"
      crit_type_value.attributes["id"] = "CRIT_TYPE"
      crit_type_value.add_element "int"
      crit_type_value.elements["int"].text = @match_types[search_terms["search"]["type"]]["id"]

      doc.elements["session/values"].add_element crit_type_value

      crit_params_wrapper_value = REXML::Element.new "value"
      crit_params_wrapper_value.attributes["id"] = @match_types[search_terms["search"]["type"]]["name"]
      crit_params_wrapper_value.add_element "valuesList"

      doc.elements["session/values"].add_element crit_params_wrapper_value

      search_terms["search"]["criteria"].each do |crit|    
        crit_param_values = REXML::Element.new "values"
        next_element = 1

        if crit["offset"] != 0
          crit_param_values.add_element "value"
          crit_param_values.elements["value"].attributes['id'] = "CRIT_CMP_VALUE_OFFSET"
          crit_param_values.elements["value"].add_element "int"
          crit_param_values.elements["value/int"].text = crit["offset"]
          next_element += 1
        end

        crit_param_values.elements.add REXML::Element.new "value"
        crit_param_values.elements[next_element, "value"].attributes['id'] = crit["offset"] != 0 ? "CRIT_CMP_CALC_VALUE" : "CRIT_CMP_VALUE"
        crit_param_values.elements[next_element, "value"].add_element "value"
        crit_param_values.elements[next_element, "value"].elements['value'].attributes['id'] = crit["name"]
        crit_param_values.elements[next_element, "value"].elements['value'].add_element crit["data_type"]
        crit_param_values.elements[next_element, "value"].elements['value/#{crit["data_type"]}'].text = crit["value"]
        next_element += 1

        crit_param_values.elements.add REXML::Element.new "value"
        crit_param_values.elements[next_element, "value"].attributes['id'] = "CRIT_CMP_OP"
        crit_param_values.elements["value[@id='CRIT_CMP_OP']"].add_element "atom"
        crit_param_values.elements["value[@id='CRIT_CMP_OP']/atom"].text = crit["op"]
        next_element += 1    

        crit_param_values.elements.add REXML::Element.new "value"
        crit_param_values.elements[next_element, "value"].attributes['id'] = "CRIT_TYPE"
        crit_param_values.elements["value[@id='CRIT_TYPE']"].add_element "int"
        crit_param_values.elements["value[@id='CRIT_TYPE']/int"].text = @match_types["value"]["id"]

        doc.elements["session/values/value[@id = 'CRIT_INTERSECT']/valuesList"].add_element crit_param_values
      end

      return doc
    end

    #
    # Performs the pre-built command-line invocation as sh(),  but doesn't use a timeout.
    # It also uses a net-ssh channel to reach the host where fcsvr_client is located
    # It also doesn't catch any exceptions raised by the IO methods.
    #
    # - command: The command to be passed to the shell, as a String.
    #
    # Returns String.
    #
    def ssh_sh(command, search_xml = nil)
      self.last_call = command
      self.last_search_xml = search_xml
      Net::SSH.start(self.class.ssh_host, self.class.ssh_username, {:verbose => Logger::FATAL, :keys => Array[self.class.ssh_private_key_file], :encryption => "3des-cbc", :hmac => "hmac-md5", :auth_methods => Array["publickey"]}) do |ssh|
        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            puts "Failure to execute command" unless success
            # puts command
            # puts search_xml
            
            ret = ""
            
            channel.on_data do |ch, data|
              @bytes_read += data.size
              ret << data
            end
            
            channel.on_extended_data do |ch, type, data|
              ret << data
            end
            
            unless search_xml.nil?
              channel.send_data(search_xml.to_s)
              channel.eof!
            end
            
            channel.on_close do |ch|
              self.last_raw_response = ret
              self.last_call = "" if self.last_call.nil?
              self.last_search_xml = "" if self.last_search_xml.nil?
              self.last_raw_response = "" if self.last_raw_response.nil?              
              return ret
            end
          end
        end
        ssh.loop
      end
    end
    
    #
    # Transform Ruby style options into fcsvr_client command line options
    # - options: Hash of Ruby-style options
    #
    # Returns String[], e.g. +["--version=10", "--noheader", "--xml"]+
    #
    def transform_options(options)
      args = []
      options.keys.each do |opt|
        if opt.to_s.size == 1   # single-character options
          # a value of 'true' means the option has no parameters (i.e. '-h')
          if options[opt] == true
            args << "-#{opt}"
          else
            val = options.delete(opt)   # retrieve value and remove from hash
            args << "-#{opt.to_s} '#{val}'"
          end
        else  # multi-character options
          if options[opt] == true
            args << "--#{opt.to_s}"
          else
            val = options.delete(opt)
            args << "--#{opt.to_s} '#{val}'"
          end
        end
      end
      args  # return the argument array
      
    end
    
  end # end class Client
  
end # end module FinalCutServer