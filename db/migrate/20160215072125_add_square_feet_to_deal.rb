class AddSquareFeetToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :sq_ft, :float
  end
end
