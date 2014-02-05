require 'bigdecimal'
require 'cexio'

module CexioReinvestor

  MIN = BigDecimal.new('0.00000001')

  class Trader
    def initialize(username, api_key, api_secret)
      @username = username
      @api_key = api_key
      @api_secret = api_secret
    end

    def api
      @api ||= CEX::API.new(@username, @api_key, @api_secret)
    end

    def trade(pair)
      to, from = pair.split('/')
      balance = BigDecimal.new(api.balance[from]['available'])
      sleep 1
      price, amount = api.order_book(pair)['asks'].first.map { |x| BigDecimal.new(x, 8) }
      sleep 1
      amount_to_buy = [ balance / price, amount ].min.round(8, :down)
      return if amount_to_buy < MIN

      result = api.place_order('buy', amount_to_buy, price, pair)
      result['pending'] = BigDecimal.new(result.fetch('pending', 0), 8)

      order_info = "#{amount_to_buy.to_s('F')} #{to} @ #{price.to_s('F')} #{from} each"
      if result['error']
        print "Could not place order for #{order_info}"
        puts " - Error was: #{result['error']}"
      else
        print "Placed order for #{order_info}"
        print " - Bought #{(amount_to_buy - result['pending']).to_s('F')}"
        print ", #{result['pending'].to_s('F')} pending" if result['pending'] > 0
        puts " - #{Time.now}"
      end
    end

    def run
      while true do
        [ 'GHS/BTC', 'GHS/NMC' ].each do |pair|
          trade(pair)
          sleep 10
        end
      end
    end
  end
end
