class AddPriceToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :price, :integer
  end
end
