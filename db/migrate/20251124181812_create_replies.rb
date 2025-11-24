class CreateReplies < ActiveRecord::Migration[8.1]
  def change
    create_table :replies do |t|
      t.text :body, null: false
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
