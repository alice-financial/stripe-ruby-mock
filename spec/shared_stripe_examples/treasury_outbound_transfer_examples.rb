require 'spec_helper'

shared_examples 'Treasury Outbound Transfer API' do

  let(:financial_account) do 
    Stripe::Treasury::FinancialAccount.create({
      supported_currencies: ["usd"],
      features: {
        card_issuing: { requested: true },
        deposit_insurance: { requested: true },
        financial_addresses: { aba: { requested: true } },
        inbound_transfers: { ach: { requested: true } },
        intra_stripe_flows: { requested: true },
        outbound_payments: {
          ach: { requested: true },
          us_domestic_wire: { requested: true }
        },
        outbound_transfers: {
          ach: { requested: true },
          us_domestic_wire: { requested: true }
        }
      }
    })
  end
  let(:payment_method) { Stripe::PaymentMethod.create(type: "us_bank_account") }

  it "creates a Treasury Outbound Transfer" do
    transfer = Stripe::Treasury::OutboundTransfer.create({
      financial_account: financial_account.id,
      amount: 100,
      currency: 'usd',
      origin_payment_method: payment_method.id,
      description: "a cool transfer"
    })

    expect(transfer.id).to match /^test_obt/
    expect(transfer.amount).to eq(100)
    expect(transfer.created).to eq(1304114826)
    expect(transfer.currency).to eq('usd')
    expect(transfer.description).to eq('a cool transfer')
    expect(transfer.financial_account).to eq(financial_account.id)
    expect(transfer.origin_payment_method).to eq(payment_method.id)
    expect(transfer.livemode).to eq(false)
    expect(transfer.metadata).to eq(Stripe::StripeObject.new)
    expect(transfer.returned_details).to be_nil
  end

  describe "listing treasury outbound transfers" do
    before do
      3.times do
        Stripe::Treasury::OutboundTransfer.create({
          financial_account: financial_account.id,
          amount: 100,
          currency: 'usd',
          origin_payment_method: payment_method.id,
          description: "a cool transfer"
        })
      end
    end

    it "without params retrieves all treasury outbound transfers" do
      expect(Stripe::Treasury::OutboundTransfer.list(financial_account: financial_account.id).count).to eq(3)
    end

    it "accepts a limit param" do
      expect(Stripe::Treasury::OutboundTransfer.list(financial_account: financial_account.id, limit: 2).count).to eq(2)
    end

    it "disallows unknown parameters" do
      expect { Stripe::Treasury::OutboundTransfer.list(recipient: "foo") }.to raise_error {|e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.param).to eq("recipient")
        expect(e.message).to eq("Received unknown parameter: recipient")
        expect(e.http_status).to eq(400)
      }
    end
  end

  it "retrieves a stripe transfer" do
    original = Stripe::Treasury::OutboundTransfer.create({
      financial_account: financial_account.id,
      amount: 100,
      currency: 'usd',
      origin_payment_method: payment_method.id,
      description: "a cool transfer"
    })
    transfer = Stripe::Treasury::OutboundTransfer.retrieve(original.id)


    expect(transfer.id).to eq(original.id)
    expect(transfer.object).to eq(original.object)
    expect(transfer.amount).to eq(original.amount)
    expect(transfer.created).to eq(original.created)
    expect(transfer.currency).to eq(original.currency)
    expect(transfer.description).to eq(original.description)
    expect(transfer.livemode).to eq(original.livemode)
    expect(transfer.metadata).to eq(original.metadata)
    expect(transfer.returned_details).to be_nil
  end

  it "cancels a stripe transfer" do
    original = Stripe::Treasury::OutboundTransfer.create({
      financial_account: financial_account.id,
      amount: 100,
      currency: 'usd',
      destination_payment_method: payment_method.id,
      description: "a cool transfer"
    })
    res, api_key = Stripe::StripeClient.active_client.execute_request(:post, "/v1/treasury/outbound_transfers/#{original.id}/cancel", api_key: 'api_key')

    expect(res.data[:status]).to eq("canceled")
  end

  it "cannot retrieve a transfer that doesn't exist" do
    expect { Stripe::Treasury::OutboundTransfer.retrieve('nope') }.to raise_error {|e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.param).to eq('transfer')
      expect(e.http_status).to eq(404)
    }
  end

  it "when amount is not integer", live: true do
    expect do 
      Stripe::Treasury::OutboundTransfer.create({
        financial_account: financial_account.id,
        amount: '400.2',
        currency: 'usd',
        origin_payment_method: payment_method.id,
        description: "a cool transfer"
      })
    end.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.param).to eq('amount')
      expect(e.http_status).to eq(400)
    }
  end

  it "when amount is negative", live: true do
    expect do 
      Stripe::Treasury::OutboundTransfer.create({
        financial_account: financial_account.id,
        amount: '-400',
        currency: 'usd',
        origin_payment_method: payment_method.id,
        description: "a cool transfer"
      })
    end.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.param).to eq('amount')
      expect(e.message).to match(/^Invalid.*integer/)
      expect(e.http_status).to eq(400)
    }
  end
end
