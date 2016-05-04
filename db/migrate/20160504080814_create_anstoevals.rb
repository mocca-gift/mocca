class CreateAnstoevals < ActiveRecord::Migration
  def change
    create_table :anstoevals do |t|
      t.references :answer, index: true, foreign_key: true
      t.references :evaluation, index: true, foreign_key: true
      t.integer :count

      t.timestamps null: false
    end
  end
end
