class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.string :portal_url
      t.decimal :rehab_cost, precision: 15, scale: 3
      t.decimal :arv_percent, precision: 15, scale: 3
      t.decimal :comps_weight, precision: 15, scale: 3
      t.decimal :zestimate_weight, precision: 15, scale: 3
      t.string :from_email
      t.string :to_email

      t.timestamps null: false
    end
  end
end
