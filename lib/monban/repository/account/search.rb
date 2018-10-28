require "getto/repository/sequel"
require "getto/repository/sequel/search"

module Monban
  # :nocov:
  module Repository
    module Account
      module Search

        class Sequel < Getto::Repository::Sequel
          def search(limit:, offset:, sort:, query:)
            search = Getto::Repository::Sequel::Search.new(limit: limit, sort: sort, query: query)

            where = search.where do |w|
              w.search "login_id.cont", &w.cont(::Sequel[:account_login_ids][:login_id])
            end
            order = search.order do |o|
              o.order :login_id, ::Sequel[:account_login_ids][:login_id]

              o.force ::Sequel[:account_login_ids][:login_id]
            end

            pages = search.pages(
              db[:accounts]
              .where(where)
              .count
            )

            accounts =
              db[:accounts]
              .left_join(:account_login_ids, account_id: :id)
              .where(where)
              .limit(limit)
              .offset(offset)
              .order(*order)
              .select(
                ::Sequel[:accounts][:id],
                ::Sequel[:account_login_ids][:login_id],
              )
              .all

            emails = db[:account_reset_password_emails]
              .where(account_id: accounts.map{|row| row[:id]})
              .group_and_count(:account_id)
              .map{|email| [email[:account_id], email[:count] > 0] }.to_h

            roles = db[:account_roles]
              .where(account_id: accounts.map{|row| row[:id]})
              .select(:account_id,:role)
              .all.group_by{|role| role[:account_id]}
              .map{|id,rows| [id, rows.map{|role| role[:role]}] }.to_h

            {
              pages: pages,
              accounts: accounts.map{|account|
                account.tap{
                  id = account[:id]
                  account[:reset] = !!emails[id]
                  account[:roles] = roles[id] || []
                }
              }
            }
          end

        end

      end
    end
  end
  # :nocov:
end
