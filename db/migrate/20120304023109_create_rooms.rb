class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :user_id
      t.string :slide_id
      t.string :title
      t.string :thumbnail
      t.string :username
      t.string :url
      t.text :description

      t.timestamps
    end
    add_index :rooms, :user_id_id
  end
end
