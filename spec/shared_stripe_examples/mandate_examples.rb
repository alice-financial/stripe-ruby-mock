require 'spec_helper'

shared_examples 'Mandates API' do
  describe 'retrieve a mandate' do
    it 'retrieves a stripe mandate' do
      mandate = Stripe::Mandate.retrieve("mandate_test")

      expect(mandate).to be_a Stripe::Mandate
      expect(mandate.id).to match /mandate\_/
    end

    it 'retrieves a stripe mandate' do
      expect do
        Stripe::Mandate.retrieve("mandate_foo")
      end.to raise_error(Stripe::InvalidRequestError, /No such mandate/)
    end
  end
end
