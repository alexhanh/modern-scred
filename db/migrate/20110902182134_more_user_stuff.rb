class MoreUserStuff < ActiveRecord::Migration
  def up
    add_column :users, :name, :string
    add_column :users, :fb_token, :string
    add_column :users, :fb_id, :string
  end

  def down
    remove_column :users, :name
    remove_column :users, :fb_token
    remove_column :users, :fb_id
  end
end
