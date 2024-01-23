module StripeMock
  module RequestHandlers
    module TreasuryOutboundTransfers

      def TreasuryOutboundTransfers.included(klass)
        klass.add_handler 'post /v1/treasury/outbound_transfers',             :new_treasury_outbound_transfer
        klass.add_handler 'get /v1/treasury/outbound_transfers',              :get_all_treasury_outbound_transfers
        klass.add_handler 'get /v1/treasury/outbound_transfers/(.*)',         :get_treasury_outbound_transfer
        klass.add_handler 'post /v1/treasury/outbound_transfers/(.*)/cancel',  :cancel_treasury_outbound_transfer
      end

      def get_all_treasury_outbound_transfers(route, method_url, params, headers)
        extra_params = params.keys - [:status, :financial_account, :ending_before,
          :limit, :starting_after]
        unless extra_params.empty?
          raise Stripe::InvalidRequestError.new("Received unknown parameter: #{extra_params[0]}", extra_params[0].to_s, http_status: 400)
        end

        if financial_account = params[:financial_account]
          assert_existence :financial_account, financial_account, treasury_financial_accounts[financial_account]
        end

        _transfers = treasury_outbound_transfers.each_with_object([]) do |(_, transfer), array|
          array << transfer if transfer[:financial_account] == financial_account
        end

        if params[:limit]
          _transfers = _transfers.first([params[:limit], _transfers.size].min)
        end

        Data.mock_list_object(_transfers, params)
      end

      def new_treasury_outbound_transfer(route, method_url, params, headers)
        id = new_id('obt')

        unless params[:amount].is_a?(Integer) || (params[:amount].is_a?(String) && /^\d+$/.match(params[:amount]))
          raise Stripe::InvalidRequestError.new("Invalid integer: #{params[:amount]}", 'amount', http_status: 400)
        end

        treasury_outbound_transfers[id] = Data.mock_treasury_outbound_transfer(params.merge :id => id)
      end

      def get_treasury_outbound_transfer(route, method_url, params, headers)
        route =~ method_url
        assert_existence :transfer, $1, treasury_outbound_transfers[$1]
        treasury_outbound_transfers[$1] ||= Data.mock_treasury_outbound_transfer(:id => $1)
      end

      def cancel_treasury_outbound_transfer(route, method_url, params, headers)
        route =~ method_url
        assert_existence :transfer, $1, treasury_outbound_transfers[$1]
        t = treasury_outbound_transfers[$1] ||= Data.mock_treasury_outbound_transfer(:id => $1)
        t.merge!({:status => "canceled"})
      end
    end
  end
end
