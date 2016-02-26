##
# lib/entity/accounts.rb
#
# Account Entity Object

module Accounts
  
  class Account
    attr_reader :id, :balance, :user_id

    def deposit(amount)
      @balance += amount
    end

    def transfer_to(account, amount)
      if !has_funds?(amount)
        raise "Balance too low"
      else
        @balance -= amount
        account.deposit(amount)
      end
    end

    def has_funds?(amount)
      @balance >= amount
    end
  end

  class Repository < Repository::RepoBase
    
    def create_for(user)
      account = create({user_id: user.id})
      account
    end

    def find_by_user(user)
      convert(@db.accounts.find_by_user_id(user.id))
    end

    def model_class
      Accounts::Account
    end
    
    def repository
      @db.account
    end
  end
end
