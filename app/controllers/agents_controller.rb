class AgentsController < ApplicationController
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @agents = Agent.order(:first_name).paginate(:page => params[:page], :per_page => Setting.i(:default_per_page))
    respond_with(@agents)
  end

  def show
    respond_with(@agent)
  end

  def new
    @agent = Agent.new
    respond_with(@agent)
  end

  def edit
  end

  def create
    @agent = Agent.new(agent_params)
    @agent.save
    respond_with(@agent)
  end

  def update
    @agent.update(agent_params)
    respond_with(@agent)
  end

  def destroy
    @agent.destroy
    respond_with(@agent)
  end

  def download
    if params[:type] == 'matrix'
      @agents = Agent.where(agent_type: 'matrix').select(:id, :first_name, :last_name, :full_name, :email, :phone, :office_name, :contact, :fax, :lic, :web_page, :broker_code).order(:first_name)
    else
      @agents = Agent.select(:id, :first_name, :last_name, :full_name, :email, :phone, :office_name, :contact, :fax, :lic, :web_page).order(:first_name)
    end

    respond_to do |format|
      format.html
      format.csv { send_data @agents.to_csv }
    end
  end

  private
    def set_agent
      @agent = Agent.find(params[:id])
    end

    def agent_params
      params.require(:agent).permit(:full_name, :first_name, :last_name, :phone, :email, :office_name)
    end
end
