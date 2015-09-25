class AddRemarkToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :remark, :text
  end
end
