class AddFriendships < ActiveRecord::Migration
  def up
    create_table(:friendships) do |t|
      t.references :user
      t.references :friend
    end
  end

  def down
    drop_table :friendships
  end
end
