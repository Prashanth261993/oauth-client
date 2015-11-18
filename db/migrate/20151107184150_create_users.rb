class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :email
      t.string :name
      t.string :access_token

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, [:provider, :uid], unique: true
    add_index :users, :access_token, unique: true
  end
end
