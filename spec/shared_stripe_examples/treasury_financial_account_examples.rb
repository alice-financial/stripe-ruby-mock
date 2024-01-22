require 'spec_helper'

shared_examples 'Treasury Financial Account API' do
  describe 'retrieve a treasury account' do
    it 'retrieves a stripe account' do
      new_account = Stripe::Treasury::FinancialAccount.create
      account = Stripe::Treasury::FinancialAccount.retrieve(new_account.id)

      expect(account).to be_a Stripe::Treasury::FinancialAccount
      expect(account.id).to match /fa\_/
    end

    it 'by default excludes account number from response' do
      new_account = Stripe::Treasury::FinancialAccount.create
      account = Stripe::Treasury::FinancialAccount.retrieve(new_account.id)

      expect(account).to be_a Stripe::Treasury::FinancialAccount
      expect(account.financial_addresses.first.aba.respond_to?(:account_number)).to be false
    end

    it 'can optionally also return account number' do
      new_account = Stripe::Treasury::FinancialAccount.create
      params = {
        id: new_account.id,
        expand: ["financial_addresses.aba.account_number"]
      }
      account = Stripe::Treasury::FinancialAccount.retrieve(params, {})

      expect(account).to be_a Stripe::Treasury::FinancialAccount
      expect(account.financial_addresses.first.aba.account_number).to eql("012344300")
    end

    it 'retrieves all' do
      accounts = Stripe::Treasury::FinancialAccount.list

      expect(accounts).to be_a Stripe::ListObject
      expect(accounts.data.count).to satisfy { |n| n >= 1 }
    end
  end

  describe 'create account' do
    it 'creates one more account' do
      account = Stripe::Treasury::FinancialAccount.create

      expect(account).to be_a Stripe::Treasury::FinancialAccount
    end
  end

  describe 'updates account' do
    it 'updates account' do
      new_account = Stripe::Treasury::FinancialAccount.create
      account = Stripe::Treasury::FinancialAccount.retrieve(new_account.id)
      account.status = 'closed'
      account.save

      account = Stripe::Treasury::FinancialAccount.retrieve(account.id)

      expect(account.status).to eq 'closed'
    end
  end
end
