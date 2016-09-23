class AddFieldsToListing < ActiveRecord::Migration
  def change
    add_column :listings, :zestimate, :decimal, precision: 15, scale: 3
    add_column :listings, :comp, :decimal, precision: 15, scale: 3
  end
end
