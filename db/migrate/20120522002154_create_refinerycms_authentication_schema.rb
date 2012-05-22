class CreateRefinerycmsAuthenticationSchema < ActiveRecord::Migration
  def change
    # Postgres apparently requires the roles_users table to exist before creating the roles table.
    create_table :roles_users, :id => false do |t|
      t.integer :user_id
      t.integer :role_id
    end

    add_index :roles_users, [:role_id, :user_id]
    add_index :roles_users, [:user_id, :role_id]

    create_table :roles do |t|
      t.string :title
    end

    create_table :user_plugins do |t|
      t.integer :user_id
      t.string  :name
      t.integer :position
    end

    add_index :user_plugins, :name
    add_index :user_plugins, [:user_id, :name], :unique => true
  end
end
