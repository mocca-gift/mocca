class AddYearToGiftcalendars < ActiveRecord::Migration
  def change
    add_column :giftcalendars, :year, :integer
  end
end
