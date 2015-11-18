class AddBrokerCodeToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :broker_code, :string
    add_column :agents, :agent_type, :string
  end
end
