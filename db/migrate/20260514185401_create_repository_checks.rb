class CreateRepositoryChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :repository_checks do |t|
      t.string :aasm_state
      t.string :check_log
      t.string :commit_id
      t.boolean :passed
      t.references :repository, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
# class CreateRepositoryChecks < ActiveRecord::Migration[8.1]
#   def change
#     create_table :repository_checks do |t|
#       t.string :commit_id
#       t.string :state, null: false, default: 'created'
#       t.integer :issues_count, default: 0
#       t.text :lint_output
#       t.references :repository, null: false, foreign_key: true, index: true

#       t.timestamps
#     end
#   end
# end