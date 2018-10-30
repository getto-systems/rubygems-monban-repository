require "getto/repository/sequel"

module Monban
  # :nocov:
  module Repository
    module Auth

      class Sequel < Getto::Repository::Sequel

        def account_id_by_public_id(public_id:, now:)
          db[:account_public_ids]
            .where(public_id: public_id)
            .where(::Sequel[:account_public_ids][:expired_at] > now)
            .select(:account_id)
            .map{|hash| hash[:account_id] }.first
        end

        def account_id_by_email(email:)
          db[:account_reset_password_emails]
            .where(email: email)
            .select(:account_id)
            .map{|hash| hash[:account_id] }.first
        end

        def account_id_by_login_id(login_id:)
          db[:account_login_ids]
            .where(login_id: login_id)
            .select(:account_id)
            .map{|hash| hash[:account_id] }.first
        end

        def login_id(account_id:)
          db[:account_login_ids]
            .where(account_id: account_id)
            .select(:login_id)
            .map{|hash| hash[:login_id]}.first
        end

        def login_type(account_id:)
          # all account login with 'authy' in this implement
          "authy"
        end

        def roles(account_id:)
          db[:account_roles]
            .where(account_id: account_id)
            .select(:role)
            .map{|r| r[:role]}
        end


        def public_id_renew_enabled?(public_id:, original_created_at:)
          not db[:account_public_ids]
            .where(public_id: public_id)
            .where(::Sequel[:account_public_ids][:original_created_at] > original_created_at)
            .empty?
        end

        def public_id_original_created_at(public_id:)
          db[:account_public_ids]
            .where(public_id: public_id)
            .select(:original_created_at)
            .map{|hash| hash[:original_created_at]}.first
        end

        def preserve_public_id_original_created_at(public_id:, original_created_at:)
          db[:account_public_ids]
            .where(public_id: public_id)
            .update(
              original_created_at: original_created_at,
            )
        end

        def public_id_exists?(public_id:)
          not db[:account_public_ids]
            .where(public_id: public_id)
            .empty?
        end

        def insert_public_id(account_id:, public_id:, created_at:, expired_at:)
          db[:account_public_ids].insert(
            account_id: account_id,
            public_id:  public_id,
            created_at: created_at,
            expired_at: expired_at,
            original_created_at: created_at,
          )
        end


        def authy_id(account_id:)
          db[:account_authy_ids]
            .where(account_id: account_id)
            .select(:authy_id)
            .map{|hash| hash[:authy_id]}.first
        end

        def update_authy_id(account_id:, authy_id:, now:)
          if db[:account_authy_ids].where(account_id: account_id).empty?
            db[:account_authy_ids].insert(
              account_id: account_id,
              authy_id:   authy_id,
              created_at: now,
            )
          else
            db[:account_authy_ids].where(account_id: account_id).update(
              authy_id:   authy_id,
              created_at: now,
            )
          end
        end


        def delete_reset_password_token(account_id:)
          db[:account_reset_password_tokens]
            .where(account_id: account_id)
            .delete
        end

        def reset_password_token_exists?(reset_token:)
          not db[:account_reset_password_tokens]
            .where(reset_token: reset_token)
            .empty?
        end

        def insert_reset_password_token(account_id:, reset_token:, created_at:, expired_at:)
          db[:account_reset_password_tokens].insert(
            account_id:  account_id,
            reset_token: reset_token,
            created_at:  created_at,
            expired_at:  expired_at,
          )
        end

        def wipe_old_reset_password_token(now:)
          db[:account_reset_password_tokens]
            .where(::Sequel[:account_reset_password_tokens][:expired_at] <= now)
            .delete
        end

        def valid_reset_password_token?(account_id:, reset_token:, now:)
          not db[:account_reset_password_tokens]
            .where(
              account_id: account_id,
              reset_token: reset_token,
            )
            .where(::Sequel[:account_reset_password_tokens][:expired_at] > now)
            .empty?
        end


        def password_salt(account_id:)
          db[:account_password_hashes]
            .select(::Sequel.function(:substring, ::Sequel[:password_hash], 1, 30).as(:salt))
            .where(account_id: account_id)
            .map{|hash| hash[:salt]}.first
        end

        def password_hash_match?(account_id:, password_hash:)
          not db[:account_password_hashes]
            .where(account_id: account_id, password_hash: password_hash)
            .empty?
        end

        def update_password_hash(account_id:, password_hash:, now:)
          if db[:account_password_hashes].where(account_id: account_id).empty?
            db[:account_password_hashes].insert(
              account_id:    account_id,
              password_hash: password_hash,
              created_at:    now,
              updated_at:    now,
            )
          else
            db[:account_password_hashes].where(account_id: account_id).update(
              password_hash: password_hash,
              updated_at:    now,
            )
          end
        end

      end

    end
  end
  # :nocov:
end
