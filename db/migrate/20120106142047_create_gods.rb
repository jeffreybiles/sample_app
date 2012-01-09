class CreateGods < ActiveRecord::Migration
  def change
    create_table :gods do |t|
      t.string :name
      t.integer :max_level
      t.string :description

      t.timestamps
    end
  end
end
