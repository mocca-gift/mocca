class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title
      t.string :link
      t.date :pubDate
      t.string :img

      t.timestamps null: false
    end
  end
end
