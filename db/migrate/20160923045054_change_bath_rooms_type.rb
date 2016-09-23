class ChangeBathRoomsType < ActiveRecord::Migration
  def change
    change_column :listings, :bath_rooms, :decimal, precision: 15, scale: 3
  end
end
