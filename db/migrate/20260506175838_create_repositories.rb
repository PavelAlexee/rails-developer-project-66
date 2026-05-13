class CreateRepositories < ActiveRecord::Migration[8.1]
  def change
    create_table :repositories do |t|
      t.string :name
      t.integer :github_id, null: false
      t.string :full_name
      t.string :language
      t.string :clone_url
      t.string :ssh_url
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
