class AddDeletedByToMessageThread < ActiveRecord::Migration
  def change
    add_column :message_threads, :deleted_by_id, :integer
  end
end
