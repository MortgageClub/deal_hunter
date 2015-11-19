class AddCountryToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :country, :string
  end
end
