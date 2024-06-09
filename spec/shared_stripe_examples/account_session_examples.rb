require 'spec_helper'

shared_examples 'AccountSession API' do
    it 'retrieves a stripe balance' do
    params = {
      account: 'my cool account',
      components: {
        payments: {
          enabled: true,
          features: {
            refund_management: true,
            dispute_management: true,
            capture_payments: true,
          },
        },
      },
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
