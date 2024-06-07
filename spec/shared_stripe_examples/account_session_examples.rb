require "spec_helper"

shared_examples "AccountSession API" do
  it "retrieves a stripe balance" do
    params = {
      account: "my cool account",
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
    account_session = Stripe::AccountSession.create()
    expect(account_session).to eq(
      {
        "object": "account_session",
        "account": params[:account],
        "client_secret": "_OXIKXxEihJokDBnDoe2sgG5OGSO2Q12shKvbeboxpALZGng",
        "expires_at": (Time.now + 1.hour).to_i,
        "livemode": false,
        "components": params[:components].deep_transform_keys { |key| key.to_s },
      }
    )
  end

  it "retrieves a stripe instant balance" do
    balance = Stripe::Balance.retrieve()
    expect(balance.instant_available[0].amount).to eq(2000)
  end
end
