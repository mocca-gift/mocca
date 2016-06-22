class CreateGiftcalendars < ActiveRecord::Migration
  def change
    create_table :giftcalendars do |t|
      t.integer :month
      t.integer :day
      t.string :name
      t.string :for_whom
      t.text :concept
      t.integer :like_count
      t.integer :dislike_count
      t.integer :judge_num

      t.timestamps null: false
    end
  end
end
