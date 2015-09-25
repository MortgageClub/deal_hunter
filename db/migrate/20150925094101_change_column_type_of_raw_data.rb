class ChangeColumnTypeOfRawData < ActiveRecord::Migration
  def change
    change_column :reports, :raw_data,  :text
  end
end
