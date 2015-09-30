class AddCompToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :comp, :decimal, precision: 15, scale: 2
  end
end
