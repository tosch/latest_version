Sequel.migration do
  change do
    create_table(:releases) do
      primary_key :id
      foreign_key :repository_id

      String :uid
      String :tag_name
      String :name
      Text :description
      String :html_url
      DateTime :published_at

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
