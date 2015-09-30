class AddHotDealColumnToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :hot_deal, :boolean, default: false
  end
end
