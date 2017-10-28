class ChangeColumnType < ActiveRecord::Migration
  def change
    change_column :listings, :lot_sz, :text
    change_column :listings, :bath_rooms, :text
    change_column :listings, :sq_ft, :text
  end
end
