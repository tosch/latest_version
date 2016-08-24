Sequel.migration do
  change do
    add_index :repositories, [:user_id, :uid], unique: true
    add_index :releases, [:repository_id, :uid], unique: true
  end
end
