class AddSomeColumnsToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :home_type, :string
    add_column :deals, :home_status, :string
    add_column :deals, :bedroom, :integer
    add_column :deals, :bathroom, :string
    add_column :deals, :dom_cdom, :string
  end
end
