Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :token
      String :username
      String :email
      String :uid

      DateTime :created_at
      DateTime :updated_at
    end

    add_index(:users, :uid, unique: true)
  end
end
