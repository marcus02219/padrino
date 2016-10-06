Sequel.migration do
  up do
    create_table :api_user_tokens do
      String :id, fixed: true, size: 36, primary_key: true
      foreign_key :user_id, :users, on_delete: :cascade, on_update: :cascade
      DateTime :created_at
      DateTime :deleted_at
    end
    create_table :api_requests do
      String :id, fixed: true, size: 36, primary_key: true
      foreign_key :api_user_token_id, :api_user_tokens, type: "char(36)", on_delete: :cascade, on_update: :cascade, null: true
      DateTime :created_at
      DateTime :deleted_at
    end
  end

  down do
    drop_table :api_requests
    drop_table :api_user_tokens
  end
end
