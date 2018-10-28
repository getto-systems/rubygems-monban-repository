Sequel.migration do
  transaction

  up do
    create_table(:accounts) do
      primary_key :id, type: :Bignum

      DateTime :created_at, null: false
    end

    create_table(:account_login_ids) do
      foreign_key :account_id, :accounts, primary_key: true, type: :Bignum

      String :login_id, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table(:account_public_ids) do
      primary_key :id, type: :Bignum
      foreign_key :account_id, :accounts, type: :Bignum

      String :public_id, null: false

      DateTime :created_at, null: false
      DateTime :expired_at, null: false
      DateTime :original_created_at, null: false

      index :public_id, unique: true
    end

    create_table(:account_roles) do
      primary_key :id, type: :Bignum
      foreign_key :account_id, :accounts, type: :Bignum

      String :role, null: false

      DateTime :created_at, null: false
    end

    create_table(:account_password_hashes) do
      foreign_key :account_id, :accounts, primary_key: true, type: :Bignum

      String :password_hash, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :password_hash
    end

    create_table(:account_authy_ids) do
      foreign_key :account_id, :accounts, primary_key: true, type: :Bignum

      Bignum :authy_id, null: false

      DateTime :created_at, null: true
      DateTime :updated_at, null: true
    end

    create_table(:account_reset_password_emails) do
      foreign_key :account_id, :accounts, primary_key: true, type: :Bignum

      String :email, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table(:account_reset_password_tokens) do
      primary_key :id, type: :Bignum
      foreign_key :account_id, :accounts, type: :Bignum

      String :reset_token, null: false

      DateTime :created_at, null: false
      DateTime :expired_at, null: false

      index :reset_token, unique: true
    end
  end

  down do
    drop_table(:account_reset_password_tokens,
               :account_reset_password_emails,
               :account_authy_ids,
               :account_password_hashes,
               :account_roles,
               :account_public_ids,
               :account_login_ids,
               :accounts)
  end
end
