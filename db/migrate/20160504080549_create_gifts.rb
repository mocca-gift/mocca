class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :name
      t.string :url
      t.binary :img, limit: 10.megabyte
      t.string :img_content_type

      t.timestamps null: false
    end
  end
end
