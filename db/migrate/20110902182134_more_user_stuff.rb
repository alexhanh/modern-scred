class MoreUserStuff < ActiveRecord::Migration
  def up
    add_column :users, :image_url, :string
    add_column :users, :name, :string
  end

  def down
    remove_column :users, :image_url
    remove_column :users, :name
  end
end
