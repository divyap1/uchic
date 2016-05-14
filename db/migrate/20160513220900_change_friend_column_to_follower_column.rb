class ChangeFriendColumnToFollowerColumn < ActiveRecord::Migration
  def change
  	rename_column :friendships, :friend_id, :following_id
  end
end
