module StripeMock
  module RequestHandlers
    # https://docs.stripe.com/api/account_sessions
    module AccountSession
      def AccountSession.included(klass)
        klass.add_handler "post /v1/account_sessions", :create_account_session
      end

      def create_account_session(route, method_url, params, headers)
        Data.mock_account_session(params)
      end
    end
  end
end
