class AddEmailToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :email, :string
  end

  def self.down
    remove_column :reviews, :email
  end
end
