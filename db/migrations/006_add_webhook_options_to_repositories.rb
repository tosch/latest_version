Sequel.migration do
  change do
    alter_table :repositories do
      add_column :webhook_send_mail, TrueClass
      add_column :webhook_send_slack, TrueClass
    end

    alter_table :users do
      add_column :slackhook_url, String
    end
  end
end
