module StripeMock
  module RequestHandlers
    module Mandates

      def Mandates.included(klass)
        klass.add_handler 'get /v1/mandates/(.*)',              :get_mandate
      end

      def get_mandate(route, method_url, params, headers)
        route =~ method_url
        init_mandate
        id = $1 || mandates.keys[0]
        mandate = mandates[id]
        assert_existence :mandate, id, mandate
        mandate
      end

      private

      def init_mandate
        if mandates == {}
          new_mandate = Data.mock_mandate
          mandates[new_mandate[:id]] = new_mandate
        end
      end
    end
  end
end
