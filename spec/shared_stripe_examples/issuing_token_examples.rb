require 'spec_helper'

shared_examples 'Issuing Tokens API' do
  describe 'list tokens' do
    it 'lists all tokens' do
      list = Stripe::Issuing::Token.list
      hashed_list = list[:data].map(&:to_hash)
      expect(hashed_list).to match_array(StripeMock::Data.mock_issuing_tokens)
    end
  end
end
