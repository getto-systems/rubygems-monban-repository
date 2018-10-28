require "getto/repository/sequel"

module Monban
  # :nocov:
  module Repository
    module Account

      class Sequel < Getto::Repository::Sequel

        def account_exists?(account_id:)
          not db[:accounts]
            .where(id: account_id)
            .empty?
        end

        def login_id_exists?(login_id:)
          not db[:account_login_ids]
            .where(login_id: login_id)
            .empty?
        end

        def login_id_account(login_id:)
          db[:account_login_ids]
            .where(login_id: login_id)
            .select(:account_id)
            .map{|hash| hash[:account_id]}.first
        end

        def reset_password_email_account(email:)
          db[:account_reset_password_emails]
            .where(email: email)
            .select(:account_id)
            .map{|hash| hash[:account_id]}.first
        end


        def login_id(account_id:)
          db[:account_login_ids]
            .where(account_id: account_id)
            .select(:login_id)
            .map{|hash| hash[:login_id]}.first
        end

        def roles(account_id:)
          db[:account_roles]
            .where(account_id: account_id)
            .select(:role)
            .map{|r| r[:role]}
        end

        def reset_password_email(account_id:)
          db[:account_reset_password_emails]
            .where(account_id: account_id)
            .select(:email)
            .map{|hash| hash[:email]}.first
        end


        def insert_account(now:)
          db[:accounts].insert(
            created_at: now,
          )
          last_insert_id
        end

        def insert_login_id(account_id:, login_id:, now:)
          db[:account_login_ids].insert(
            account_id: account_id,
            login_id:   login_id,
            created_at: now,
            updated_at: now,
          )
        end


        def update_reset_password_email(account_id:, email:, now:)
          where = {
            account_id: account_id,
          }
          if db[:account_reset_password_emails].where(where).empty?
            db[:account_reset_password_emails].insert(
              account_id: account_id,
              email:      email,
              created_at: now,
              updated_at: now,
            )
          else
            db[:account_reset_password_emails].where(where).update(
              email:      email,
              updated_at: now,
            )
          end
        end

        def update_login_id(account_id:, login_id:, now:)
          where = {
            account_id: account_id,
          }
          if login_id.empty?
            db[:account_login_ids].where(where).delete
          else
            if db[:account_login_ids].where(where).empty?
              db[:account_login_ids].insert(
                  account_id: account_id,
                  login_id:   login_id,
                  updated_at: now,
                  created_at: now,
                )
            else
              db[:account_login_ids]
                .where(account_id: account_id)
                .update(
                  login_id:   login_id,
                  updated_at: now,
                )
            end
          end
        end

        def update_roles(account_id:, roles:, now:)
          old_roles = db[:account_roles]
            .where(account_id: account_id)
            .select(:role)
            .map{|hash| hash[:role]}

          roles.each do |role|
            unless old_roles.delete(role.to_s)
              db[:account_roles].insert(
                account_id: account_id,
                role:       role.to_s,
                created_at: now,
              )
            end
          end

          old_roles.each do |role|
            db[:account_roles]
              .where(
                account_id: account_id,
                role:       role,
              )
              .delete
          end
        end


        def delete_account(account_id:)
          [
            #:account_public_ids, # DO NOT DELETE public_id
            :account_login_ids,
            :account_authy_ids,
            :account_password_hashes,
            :account_reset_password_tokens,
            :account_roles,
            :account_reset_password_emails,
          ].each do |table|
            db[table].where(account_id: account_id).delete
          end

          # nullify account_id instead of delete rows
          db[:account_public_ids]
            .where(account_id: account_id)
            .update(account_id: nil)

          db[:accounts].where(id: account_id).delete
        end

      end

    end
  end
  # :nocov:
end
