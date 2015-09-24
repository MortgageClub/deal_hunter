class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.text :reply
      t.integer :messageable_id
      t.string :messageable_type
      t.string :phone_number
      t.string :status

      t.timestamps null: false
    end
  end
end
