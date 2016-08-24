Sequel.migration do
  change do
    alter_table :repositories do
      add_column :webhook_secret, String
      add_column :webhook_uid, String
    end
  end
end
