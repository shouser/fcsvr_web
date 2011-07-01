class EntityController < ApplicationController
  before_filter :setup_client
  
  def show
    asset = FinalCutServer::Asset.new(@client, ["/" + params[:type] + "/" + params[:id]])
    update_cmd_history

    @md = asset.get_clean_metadata
    update_cmd_history

    respond_to do |format|
      format.xml  { render :xml => @md.to_xml }
      format.json { render :json => @md.to_json }
    end
  end

  def search
    post_data = request.body.read
    json_search_params = JSON.parse(post_data)
    
    result_set = FinalCutServer::FCSEntity.search_for(["/" + params[:type]], nil, {:xml => true, :xmlcrit => true, :search_hash => json_search_params})
    update_cmd_history
    
    @results = []
    result_set.each do |result|
      @results << result.get_clean_metadata
      update_cmd_history
    end

    respond_to do |format|
      format.xml { render :xml => @results.to_xml }
      format.json { render :json => @results.to_json }
    end
  end

  def get_asset_reps
    asset = FinalCutServer::Asset.new(@client, ["/asset/" + params[:id]])
    update_cmd_history
    
    @results = asset.get_location_for_asset_rep
    update_cmd_history
    
    respond_to do |format|
      format.xml { render :xml => @results.to_xml }
      format.json { render :json => @results.to_json }
    end
  end
  
  def get_project_tree
    project = FinalCutServer::Project.new(@client, ["/project/" + params[:id]])
    update_cmd_history
   
    results = project.get_project_heirarchy
    update_cmd_history
    
    @result_hash = convert_tree_to_hash(results)
    
    respond_to do |format|
      format.xml { render :xml => @result_hash.to_xml }
      format.json { render :json => @result_hash.to_json }
    end
  end
  
  def update

    post_data = request.body.read
    json_search_params = JSON.parse(post_data)
    
    options = Hash.new
    options[:xml] = true
    options[:sudo] = true
    options[:xmlmd_hash] = json_search_params

    @client.setmd options,  ["/" + params[:type] + "/" + params[:id]]
    update_cmd_history
    
    asset = FinalCutServer::Asset.new @client, ["/" + params[:type] + "/" + params[:id]]
    update_cmd_history

    @md = asset.get_clean_metadata
    update_cmd_history

    respond_to do |format|
      format.xml  { render :xml => @md.to_xml }
      format.json { render :json => @md.to_json }
    end
  end
  
  def create
    post_data = request.body.read
    json_search_params = JSON.parse(post_data)

    created_asset_path = @client.create_asset(json_search_params["source_file_path"], json_search_params["source_file_name"], json_search_params["device_addr"], json_search_params["description"], json_search_params["keywords"], json_search_params["project_addr"], json_search_params["asset_type"], json_search_params["remove_original_file"], json_search_params["trigger_analyze"])
    update_cmd_history
    
    asset = FinalCutServer::Asset.new @client, created_asset_path
    
    @md = asset.get_clean_metadata
    update_cmd_history
    
    respond_to do |format|
      format.xml  { render :xml => @md.to_xml }
      format.json { render :json => @md.to_json }
    end
  end
  
  def create_with_rep_links
    post_data = request.body.read

    created_asset_path = @client.create_asset_with_reps post_data
    update_cmd_history
    
    asset = FinalCutServer::Asset.new @client, created_asset_path
    rep_links = asset.get_location_for_asset_rep
    update_cmd_history

    md = asset.get_clean_metadata
    update_cmd_history

    @results = { :md => md, :rep_links => rep_links }
    
    respond_to do |format|
      format.xml  { render :xml => @results.to_xml }
      format.json { render :json => @results.to_json }
    end
  end
  
  private
  def setup_client
    @client = FinalCutServer::Client.new

    @client.class.ssh_username = "shouser"
    @client.class.ssh_private_key_file = "~/.ssh/id_rsa"
    @client.class.ssh_host = "shaithus.chickenkiller.com"
  end
  
  def convert_tree_to_hash(tree)
    tree_hash = Hash.new
    tree.each do |element|
      if element.is_leaf? then
        return element.name
      else
        tree_hash[element.name] = Hash.new
        tree_hash[element.name] = Array.new
        element.children do |child|
          tree_hash[element.name] << convert_tree_to_hash(child)
        end
        return tree_hash
      end
    end
  end
  
  def update_cmd_history
    fcscmdhistory = FcsvrCmdHistory.new
    fcscmdhistory.cmd_executed = 'echo "' + @client.last_search_xml.to_s + '" | ' + @client.last_call
    fcscmdhistory.raw_response = @client.last_raw_response
    fcscmdhistory.save
  end
end
