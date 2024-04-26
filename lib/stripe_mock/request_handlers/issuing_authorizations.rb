module StripeMock
  module RequestHandlers
    module IssuingCards
      def IssuingCards.included(klass)
        klass.add_handler 'post /v1/issuing/cards',               :new_issuing_card
        klass.add_handler 'get /v1/issuing/cards/([^/]*)',        :get_issuing_card
        klass.add_handler 'get /v1/issuing/cards/([^/]*)/details',:get_issuing_card_details
        klass.add_handler 'post /v1/issuing/cards/([^/]*)',       :update_issuing_card
        klass.add_handler 'get /v1/issuing/cards',                :list_issuing_cards
      end

      def new_issuing_card(route, method_url, params, headers)
        params[:id] ||= new_id('ic')
        ensure_issuing_card_params(params)
        cardholder = cardholders[params.delete(:cardholder)]
        issuing_cards[params[:id]] = Data.mock_issuing_card(cardholder, params)
      end

      def get_issuing_card(route, method_url, params, headers)
        route =~ method_url
        assert_existence :issuing_card, $1, issuing_cards[$1]
      end

      def get_issuing_card_details(route, method_url, params, headers)
        route =~ method_url
        card = assert_existence :issuing_card, $1, issuing_cards[$1]
        raise Stripe::InvalidRequestError.new("Cant request details of a physical card", 'issuing_type', http_status: 400) unless 'virtual' == card[:type]
        {
            object: "issuing.card_details",
            card: card,
            cvc: '123',
            exp_month: card[:exp_month],
            exp_year: card[:exp_year],
            number: '4000009990000070'
        }
      end

      def list_issuing_cards(route, method_url, params, headers)
        Data.mock_list_object(issuing_cards.values, params)
      end

      def update_issuing_card(route, method_url, params, headers)
        route =~ method_url
        card = assert_existence :issuing_card, $1, issuing_cards[$1]
        card.merge!(params)
      end

      private

      def ensure_issuing_card_params(params)
        raise Stripe::InvalidRequestError.new("There is no default cardholder for this account", 'cardholder', http_status: 400) unless params[:cardholder]
        require_param(:currency) unless params[:currency]
        require_param(:type) unless params[:type]
        raise Stripe::InvalidRequestError.new("No such issuing cardholder: #{params[:cardholder]}", 'cardholder', http_status: 400) unless cardholders[params[:cardholder]]
        raise Stripe::InvalidRequestError.new("Invalid currency: #{params[:currency]}. Stripe currently supports these currencies: usd", 'cardholder', http_status: 400) unless 'usd' ==params[:currency]
        raise Stripe::InvalidRequestError.new("Invalid type: must be one of physical or virtual", 'issuing_type', http_status: 400) unless %w{physical virtual}.include?(params[:type])
        if params[:type] == 'physical'
          require_param(:shipping) unless params[:shipping]
          require_param('shipping[name]') unless params[:shipping][:name]
          require_param('shipping[address]') unless params[:shipping][:address]
          node =  params[:shipping][:address]
          require_param('shipping[address][line1]') unless node[:line1]
          require_param('shipping[address][city]') unless node[:city]
          require_param('shipping[address][country]') unless node[:country]
          require_param('shipping[address][state]') unless node[:state]
          require_param('shipping[address][postal_code]') unless node[:postal_code]
        end
      end
    end
  end
end
