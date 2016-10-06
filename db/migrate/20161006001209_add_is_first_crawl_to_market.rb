class AddIsFirstCrawlToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :is_first_crawl, :boolean
  end
end
