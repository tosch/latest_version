Sequel.migration do
  change do
    create_table(:repositories) do
      primary_key :id
      foreign_key :user_id

      String :uid
      String :full_name
      String :url
      String :html_url
      String :releases_url

      DateTime :created_at
      DateTime :updated_at
    end

    add_index :repositories, :updated_at
  end
end
