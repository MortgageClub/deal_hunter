class AddAddedDateToListing < ActiveRecord::Migration
  def change
    add_column :listings, :added_date, :datetime
  end
end
