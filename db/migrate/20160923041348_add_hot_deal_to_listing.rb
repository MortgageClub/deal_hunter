class AddHotDealToListing < ActiveRecord::Migration
  def change
    add_column :listings, :hot_deal, :boolean
  end
end
