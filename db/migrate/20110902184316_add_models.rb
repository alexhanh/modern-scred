class AddModels < ActiveRecord::Migration
  def up
    create_table(:transfers) do |t|
      t.references :creator
      t.references :debtor
      t.references :creditor
      t.float :amount
      t.string :message
      t.timestamps
    end
  end

  def down
    drop_table :transfers
  end
end
