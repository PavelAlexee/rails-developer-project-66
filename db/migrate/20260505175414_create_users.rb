class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :image_url
      t.string :nickname
      t.string :token

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
