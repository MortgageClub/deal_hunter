class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string :listing_id
      t.decimal :price, precision: 15, scale: 2
      t.decimal :zestimate, precision: 15, scale: 2
      t.string :address
      t.string :city
      t.string :zipcode
      t.string :status
      t.references :agent, index: true

      t.timestamps
    end
  end
end
