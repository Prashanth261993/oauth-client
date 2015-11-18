class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :author
      t.text :content
      t.string :name
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
