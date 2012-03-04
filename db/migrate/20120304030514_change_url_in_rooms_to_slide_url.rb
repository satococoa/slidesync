class ChangeUrlInRoomsToSlideUrl < ActiveRecord::Migration
  def change
    rename_column :rooms, :url, :slide_url
  end
end
