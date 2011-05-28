class GetmdController < ApplicationController
  def show
    fcsc = FcsvrConnector::FcsClient.new
    
    @md = fcsc.getmd("/" + params[:type] + "/" + params[:id])
    
    fch = FcsvrCmdHistory.new
    fch.cmd_executed = @md["cmd_executed"]
    fch.raw_response = @md["raw_xml_response"]
    fch.dry_run = false
    fch.save
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @md['raw_xml_response'] }
    end
  end
  
  def search
    @xml_body = Hash.from_xml(request.raw_post)
    fcsc = FcsvrConnector::FcsClient.new
    sxb = FcsvrConnector::SearchXmlBuilder.new
    unless @xml_body['search']['crits'].nil?
      if(@xml_body['search']['crits']['crit'].is_a?(Array))
        @xml_body['search']['crits']['crit'].each do |crit|
          if crit['type'] == 'time'
            sxb.addTimeSearchCriteria(crit['id'], crit['value'], crit['op'], crit['offset'].to_i)
          else
            sxb.addSearchCriteria(crit['id'], crit['value'], crit['type'], (crit['op'].nil? ? "eq" : crit['op']), (crit['offset'].nil? ? "0" : crit['offset']))
          end
        end
      else
        @xml_body['search']['crits'].each_value do |crit|
          if crit['type'] == 'time'
            sxb.addTimeSearchCriteria(crit['id'], crit['value'], crit['op'], crit['offset'].to_i)
          else
            sxb.addSearchCriteria(crit['id'], crit['value'], crit['type'], (crit['op'].nil? ? "eq" : crit['op']), (crit['offset'].nil? ? "0" : crit['offset']))
          end
        end
      end
    end
    @display = fcsc.search(sxb, @xml_body['search']['device'])
    fch = FcsvrCmdHistory.new
    fch.cmd_executed = @display["cmd_executed"]
    fch.raw_response = @display["raw_xml_response"]
    fch.dry_run = false
    fch.save
    respond_to do |format|
      format.html
      format.xml { render :xml => @display['raw_xml_response'] }
    end
  end
end
