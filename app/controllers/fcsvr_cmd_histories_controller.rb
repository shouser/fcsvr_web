class FcsvrCmdHistoriesController < ApplicationController
  def index
    @fcsvr_cmd_history = FcsvrCmdHistory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fcsvr_cmd_history }
      format.json { render :json => @fcsvr_cmd_history }
    end
  end
end
