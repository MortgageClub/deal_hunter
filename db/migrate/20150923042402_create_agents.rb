class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.string :office_name

      t.timestamps
    end
  end
end
