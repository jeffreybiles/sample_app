class CreateFavors < ActiveRecord::Migration
  def change
    create_table :favors do |t|
      t.integer :user_id
      t.integer :god_id
      t.integer :level
      t.float :experience

      t.timestamps
    end

    add_index :favors, :user_id
    add_index :favors, :god_id
    add_index :favors, [:user_id, :god_id], uniqueness: true
  end
end
