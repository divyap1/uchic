class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :reviewer
      t.belongs_to :user
      t.integer :rating
      t.text :comment
      t.timestamps
    end
  end
end
