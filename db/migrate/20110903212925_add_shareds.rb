class AddShareds < ActiveRecord::Migration
  def up
    create_table(:shareds) do |t|
    end
  end

  def down
    drop_table :shareds
  end
end
