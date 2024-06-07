module StripeMock
  module RequestHandlers
    module AccountSessions
      def AccountSessions.included(klass)
        klass.add_handler "post /v1/account_sessions", :create_account_session
      end

      def create_account_session(route, method_url, params, headers)
        Data.mock_account_session(params)
      end
    end
  end
end
