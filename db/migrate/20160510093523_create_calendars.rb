class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.integer :month
      t.integer :day
      t.string :name1
      t.string :name2
      t.string :name3

      t.timestamps null: false
    end
  end
end
