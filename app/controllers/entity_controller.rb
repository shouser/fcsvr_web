class EntityController < ApplicationController
  def show
    client = FinalCutServer::Client.new

    client.class.ssh_username = "shouser"
    client.class.ssh_private_key_file = "~/.ssh/id_rsa"
    client.class.ssh_host = "cook.local"

    asset = FinalCutServer::Asset.new(client, ["/" + params[:type] + "/" + params[:id]])
    fcscmdhistory = FcsvrCmdHistory.new
    fcscmdhistory.cmd_executed = 'echo "' + client.last_search_xml + '" | ' + client.last_call
    fcscmdhistory.raw_response = client.last_raw_response
    fcscmdhistory.save
    
    asset.load_metadata
    @md = asset.metadata

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @md.to_xml }
      format.json { render :json => @md.to_json }
    end
  end

  def search
    client = FinalCutServer::Client.new

    client.class.ssh_username = "shouser"
    client.class.ssh_private_key_file = "~/.ssh/id_rsa"
    client.class.ssh_host = "cook.local"

    post_data = request.body.read
    json_search_params = JSON.parse(post_data)
    
    result_set = FinalCutServer::FCSEntity.search_for(["/" + params[:type]], nil, {:xml => true, :xmlcrit => true, :search_hash => json_search_params})
    fcscmdhistory = FcsvrCmdHistory.new
    fcscmdhistory.cmd_executed = 'echo "' + client.last_search_xml + '" | ' + client.last_call
    fcscmdhistory.raw_response = client.last_raw_response
    fcscmdhistory.save
    
    @results = []
    result_set.each do |result|
      result.load_metadata
      @results << result.metadata
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @results.to_xml }
      format.json { render :json => @results.to_json }
    end
  end

  def get_asset_reps
    client = FinalCutServer::Client.new

    client.class.ssh_username = "shouser"
    client.class.ssh_private_key_file = "~/.ssh/id_rsa"
    client.class.ssh_host = "cook.local"

    asset = FinalCutServer::Asset.new(client, ["/asset/" + params[:id]])
    
    @results = asset.get_location_for_asset_rep
    fcscmdhistory = FcsvrCmdHistory.new
    fcscmdhistory.cmd_executed = 'echo "' + client.last_search_xml + '" | ' + client.last_call
    fcscmdhistory.raw_response = client.last_raw_response
    fcscmdhistory.save
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @results.to_xml }
      format.json { render :json => @results.to_json }
    end
  end
  
  def update
    client = FinalCutServer::Client.new

    client.class.ssh_username = "shouser"
    client.class.ssh_private_key_file = "~/.ssh/id_rsa"
    client.class.ssh_host = "cook.local"

    asset = FinalCutServer::Asset.new(client, ["/" + params[:type] + "/" + params[:id]])
    fcscmdhistory = FcsvrCmdHistory.new
    fcscmdhistory.cmd_executed = 'echo "' + client.last_search_xml + '" | ' + client.last_call
    fcscmdhistory.raw_response = client.last_raw_response
    fcscmdhistory.save
    
    asset.load_metadata    
    @md = asset.metadata

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @md.to_xml }
      format.json { render :json => @md.to_json }
    end
  end
end
