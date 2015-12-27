class AddRememberDigestToUser < ActiveRecord::Migration
  def change
    add_column :users, :remember_token_digest, :string
  end
end
