class CreateTables < ActiveRecord::Migration
  def change
    create_table :actors, :id => false do |t|
      t.bigint :id, null: false, unique: true#, primary_key: true
      t.string :login
      t.string :avatar_url
    end
    Actor.primary_key = "id"
    add_index :actors, :id, unique: true


    create_table :repos, :id => false do |t|
      t.bigint :id, null: false, unique: true#, primary_key: true
      t.text :name
      t.text :url
    end
    Repo.primary_key = "id"
    add_index :repos, :id, unique: true
#    add_foreign_key :actors, :events, column: :actor_id#, on_delete: :cascade
 #   add_foreign_key :repos, :events, column: :repo_id#, on_delete: :cascade

 
    create_table :events, :id => false do |t|
      t.bigint :id, null: false, unique: true#, primary_key: true
      t.text :type
      t.timestamp :created_at
      t.bigint :actor_id
      t.bigint :repo_id
      # t.references :actor, index: true, foreign_key: true
    end
    Event.primary_key = "id"
    add_index :events, :id, unique: true



    

  end
end
