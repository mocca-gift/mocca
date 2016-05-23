class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :gift, index: true, foreign_key: true
      t.integer :evalid
      t.integer :count

      t.timestamps null: false
    end
  end
end
