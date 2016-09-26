class AddNameToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :name, :string
  end
end
