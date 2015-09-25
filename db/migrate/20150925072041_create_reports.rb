class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :result
      t.string :raw_data

      t.timestamps null: false
    end
  end
end
