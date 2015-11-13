class ChangeAttributesOfAgents < ActiveRecord::Migration
  def change
    change_column :agents, :full_name, :text
    change_column :agents, :contact, :text
    change_column :agents, :fax, :text
    change_column :agents, :lic, :text
    change_column :agents, :web_page, :text
    change_column :agents, :office_name, :text
  end
end
