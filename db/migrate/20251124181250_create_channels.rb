class CreateChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :channels do |t|
      t.string :name, null: false
      t.text :description
      t.string :privacy, null: false, default: 'public'
      t.references :workspace, null: false, foreign_key: true

      t.timestamps
    end
  end
end
