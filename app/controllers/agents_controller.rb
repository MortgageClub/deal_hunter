class AgentsController < ApplicationController
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @agents = Agent.all
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

  private
    def set_agent
      @agent = Agent.find(params[:id])
    end

    def agent_params
      params.require(:agent).permit(:full_name, :first_name, :last_name, :phone, :email, :office_name)
    end
end
