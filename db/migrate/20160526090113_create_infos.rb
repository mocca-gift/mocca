class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.string :title
      t.text :content
      t.binary :img, limit: 10.megabyte
      t.string :img_content_type

      t.timestamps null: false
    end
  end
end
