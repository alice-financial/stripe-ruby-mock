module StripeMock
  module RequestHandlers
    module TreasuryFinancialAccounts

      def TreasuryFinancialAccounts.included(klass)
        klass.add_handler 'post /v1/treasury/financial_accounts',      :new_treasury_financial_account
        klass.add_handler 'get /v1/treasury/financial_account',        :get_treasury_financial_account
        klass.add_handler 'get /v1/treasury/financial_accounts/(.*)',  :get_treasury_financial_account
        klass.add_handler 'post /v1/treasury/financial_accounts/(.*)', :update_treasury_financial_account
        klass.add_handler 'get /v1/treasury/financial_accounts',       :list_treasury_financial_accounts
      end

      def new_treasury_financial_account(route, method_url, params, headers)
        params[:id] ||= new_id('fa')
        route =~ method_url
        treasury_financial_accounts[params[:id]] ||= Data.mock_treasury_financial_account(params)
      end

      def get_treasury_financial_account(route, method_url, params, headers)
        route =~ method_url
        init_treasury_financial_account
        id = $1 || treasury_financial_accounts.keys[0]
        acct = treasury_financial_accounts[id]
        assert_existence :treasury_financial_account, id, acct
        if params && params[:expand] && params[:expand].include?("financial_addresses.aba.account_number")
          acct
        else
          sanitized_acct = acct
          sanitized_acct[:financial_addresses].first[:aba].delete(:account_number)
          sanitized_acct
        end
      end

      def update_treasury_financial_account(route, method_url, params, headers)
        route =~ method_url
        treasury_financial_account = assert_existence :treasury_financial_account, $1, treasury_financial_accounts[$1]
        treasury_financial_account.merge!(params)
        treasury_financial_account
      end

      def list_treasury_financial_accounts(route, method_url, params, headers)
        init_treasury_financial_account
        Data.mock_list_object(treasury_financial_accounts.values, params)
      end

      def deauthorize(route, method_url, params, headers)
        init_treasury_financial_account
        route =~ method_url
        Stripe::StripeObject.construct_from(:stripe_user_id => params[:stripe_user_id])
      end

      private

      def init_treasury_financial_account
        if treasury_financial_accounts == {}
          acc = Data.mock_treasury_financial_account
          treasury_financial_accounts[acc[:id]] = acc
        end
      end
    end
  end
end
