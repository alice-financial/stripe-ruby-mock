require 'spec_helper'

shared_examples 'AccountSession API' do
  it 'creates a stripe Account Session' do
    account = "acct_my_cool_account"
    # https://docs.stripe.com/api/account_sessions/create
    params = {
      account:,
      components: {
        payments: {
          enabled: true,
          features: { refund_management: true, dispute_management: true, capture_payments: true }
        }
      }
    }
    account_session = Stripe::AccountSession.create(params)
    expect(account_session).to be_a Stripe::AccountSession
    expect(account_session.to_hash).to eq({
      object: 'account_session',
      account: params[:account],
      client_secret: '_OXIKXxEihJokDBnDoe2sgG5OGSO2Q12shKvbeboxpALZGng',
      expires_at: (Time.now + 3600).to_i,
      livemode: false,
      components: params[:components],
    })
  end

end
