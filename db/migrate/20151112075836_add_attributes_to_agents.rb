class AddAttributesToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :contact, :string
    add_column :agents, :fax, :string
    add_column :agents, :lic, :string
    add_column :agents, :web_page, :string
    add_column :agents, :address, :text
  end
end