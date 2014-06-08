require 'bigdecimal'
require 'cexio'

module CexioReinvestor

  MIN = BigDecimal.new('0.00000001')
  FEE_ADJUSTMENT = BigDecimal.new('1.002012141')

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
      price = BigDecimal.new(api.ticker(pair)['ask'], 8)
      sleep 1
      amount_to_buy = (balance / price / FEE_ADJUSTMENT).round(8, :down)
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
    rescue Timeout::Error
      :timeout
    rescue JSON::ParserError
      :invalid_response
    end

    def run
      while true do
        [ 'GHS/BTC', 'GHS/NMC' ].each do |pair|
          case trade(pair)
          when :timeout
            puts "Timed out when trying to contact CEX.io."
          when :invalid_response
            puts "Hit CEX.io API request limit, will sleep for a bit."
            sleep 240
          end
          sleep 120
        end
      end
    end
  end
end
