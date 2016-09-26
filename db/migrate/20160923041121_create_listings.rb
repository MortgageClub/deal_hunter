class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.string :chg_type
      t.string :mls
      t.string :address
      t.string :city
      t.decimal :sq_ft, precision: 15, scale: 3
      t.integer :year_built
      t.integer :bed_rooms
      t.integer :bath_rooms
      t.decimal :price, precision: 15, scale: 3
      t.decimal :lot_sz, precision: 15, scale: 3
      t.references :market, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end


