class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :wins
      t.string :name

      t.timestamps null: false
    end
  end
end
