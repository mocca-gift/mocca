class CreateFbtalks < ActiveRecord::Migration
  def change
    create_table :fbtalks do |t|
      t.string :user
      t.string :answer
      t.string :question
      t.string :qflowid

      t.timestamps null: false
    end
  end
end
