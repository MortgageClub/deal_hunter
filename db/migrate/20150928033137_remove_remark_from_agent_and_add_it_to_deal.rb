class RemoveRemarkFromAgentAndAddItToDeal < ActiveRecord::Migration
  def change
    remove_column :agents, :remark
    add_column :deals, :remark, :text
  end
end
