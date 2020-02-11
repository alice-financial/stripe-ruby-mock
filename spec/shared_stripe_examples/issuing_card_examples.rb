require 'spec_helper'

shared_examples 'Issuing Cards API' do
  let(:cardholder) {Stripe::Issuing::Cardholder.create(cardholder_params)}
  let(:cardholder_params) {{
      type: 'individual',
      name: 'Bo Diddley',
      billing: {
          address: {
              line1: '123 high street',
              city: 'Brooklyn',
              state: 'CA',
              country: 'US',
              postal_code: '11201'
          }
      }
  }}
  let(:params) {{
      type: 'virtual',
      cardholder: cardholder.id,
      currency: 'usd'
  }}

  describe 'list cards' do
    it 'lists all cards' do
      c1 = Stripe::Issuing::Card.create(params)
      c2 = Stripe::Issuing::Card.create(params)
      list = Stripe::Issuing::Card.list
      expect(list[:data]).to include(c1, c2)
    end
  end


  context 'update card' do
    it 'updates the cardholder' do
      card = Stripe::Issuing::Card.create(params)
      result = Stripe::Issuing::Card.update(card.id, { status: 'active' })
      expect(result.status).to eq('active')
    end
  end

  context 'create card' do
    it 'creates a cardholder' do
      cardholder = Stripe::Issuing::Card.create(params)
      expect(cardholder.object).to eq('issuing.card')
      expect(cardholder).to be_a Stripe::Issuing::Card
      expect(cardholder.id).to match(/ic_/)
    end
    describe 'Errors' do
      context 'missing type' do
        it 'throws error' do
          params.delete(:type)
          expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: type/)
        end
      end
      context 'missing cardholder' do
        it 'throws error' do
          params.delete(:cardholder)
          expect {Stripe::Issuing::Card.create(params)}.to raise_error(/There is no default cardholder for this account/)
        end
      end

      context 'wrong cardholder' do
        it 'throws error' do
          params[:cardholder] = 'foo'
          expect {Stripe::Issuing::Card.create(params)}.to raise_error(/No such issuing cardholder: foo/)
        end
      end
      context 'missing currency' do
        it 'throws error' do
          params.delete(:currency)
          expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: currency/)
        end
      end
      context 'wrong currency' do
        it 'throws error' do
          params[:currency] = 'gbp'
          expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Invalid currency: gbp. Stripe currently supports these currencies: usd/)
        end
      end
      context 'wrong type' do
        it 'throws error' do
          params[:type] = 'gbp'
          expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Invalid type: must be one of physical or virtual/)
        end
      end
      context 'physical cards' do
        let(:params) {{
            type: 'physical',
            cardholder: cardholder.id,
            currency: 'usd',
            shipping: {
                name: 'foo',
                address: {
                    line1: 'line1',
                    city: 'Brooklyn',
                    state: 'CA',
                    country: 'US',
                    postal_code: '11201'
                }
            }
        }}
        context 'shipping missing' do
          it 'throws error' do
            params.delete(:shipping)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping/)
          end
        end
        context 'shipping name missing' do
          it 'throws error' do
            params[:shipping].delete(:name)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[name\]/)
          end
        end
        context 'shipping address missing' do
          it 'throws error' do
            params[:shipping].delete(:address)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[address\]/)
          end
        end
        context 'shipping address line1 missing' do
          it 'throws error' do
            params[:shipping][:address].delete(:line1)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[address\]\[line1\]/)
          end
        end
        context 'shipping address city missing' do
          it 'throws error' do
            params[:shipping][:address].delete(:city)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[address\]\[city\]/)
          end
        end
        context 'shipping address state missing' do
          it 'throws error' do
            params[:shipping][:address].delete(:state)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[address\]\[state\]/)
          end
        end
        context 'shipping address country missing' do
          it 'throws error' do
            params[:shipping][:address].delete(:country)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[address\]\[country\]/)
          end
        end
        context 'shipping address postal_code missing' do
          it 'throws error' do
            params[:shipping][:address].delete(:postal_code)
            expect {Stripe::Issuing::Card.create(params)}.to raise_error(/Missing required param: shipping\[address\]\[postal_code\]/)
          end
        end
      end
    end
  end


  context 'get card' do

    it 'retreives an existing cardholder' do
      card = Stripe::Issuing::Card.create(params)
      retreived = Stripe::Issuing::Card.retrieve(card.id)
      expect(retreived).to eq(card)
    end
    describe 'Errors' do
      it 'throws an error if the cardholder doesnt exist' do
        expect {
          Stripe::Issuing::Card.retrieve('foo')
        }.to raise_error {|e|
          expect(e).to be_a(Stripe::InvalidRequestError)
          expect(e.message).to eq('No such issuing_card: foo')
        }
      end
    end
  end


  context 'get issuing card details' do
    let(:card) {Stripe::Issuing::Card.create(params)}
    context 'virtual card' do

      it 'returns a card details object' do
        res = Stripe::Issuing::Card.details(card.id)
        expect(res.object).to eq 'issuing.card_details'
        expect(res.cvc).not_to be_nil
        expect(res.exp_month).to eq(card.exp_month)
        expect(res.exp_year).to eq(card.exp_year)
        expect(res.number).not_to be_nil
      end
    end
    context 'physical card' do
      let(:params) {{
          type: 'physical',
          cardholder: cardholder.id,
          currency: 'usd',
          shipping: {
              name: 'foo',
              address: {
                  line1: 'line1',
                  city: 'Brooklyn',
                  state: 'CA',
                  country: 'US',
                  postal_code: '11201'
              }
          }
      }}
      it 'raises an error' do
        expect {Stripe::Issuing::Card.details(card.id)}.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end

end