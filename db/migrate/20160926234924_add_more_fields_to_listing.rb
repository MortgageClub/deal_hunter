class AddMoreFieldsToListing < ActiveRecord::Migration
  def change
    add_column :listings, :rent, :decimal, precision: 15, scale: 3
    add_column :listings, :arv, :decimal, precision: 15, scale: 3
    add_column :listings, :arv_percentage, :decimal, precision: 15, scale: 4
    add_column :listings, :is_sent, :boolean
  end
end
