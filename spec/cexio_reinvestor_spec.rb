require 'spec_helper'

describe CexioReinvestor::Trader do

  let(:trader) { CexioReinvestor::Trader.new('username', 'api_key', 'api_secret') }

  describe '#trade(pair)' do
    it 'does not blow up when a timeout occurs' do
      stub_request(:post, 'https://cex.io/api/balance/').to_timeout
      expect do
        expect(trader.trade('GHS/BTC')).to eq :timeout
      end.not_to raise_error
    end

    it 'does not blow up when a parser error occurs' do
      stub_request(:post, 'https://cex.io/api/balance/').to_return body: '<html></html>'
      expect do
        expect(trader.trade('GHS/BTC')).to eq :invalid_response
      end.not_to raise_error
    end
  end
end

