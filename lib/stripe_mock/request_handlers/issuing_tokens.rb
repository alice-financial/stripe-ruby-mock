module StripeMock
  module RequestHandlers
    module IssuingTokens
      def IssuingTokens.included(klass)
        klass.add_handler 'get /v1/issuing/tokens', :list_issuing_tokens
      end

      def list_issuing_tokens(route, method_url, params, headers)
        Data.mock_list_object(issuing_tokens, params)
      end
    end
  end
end
