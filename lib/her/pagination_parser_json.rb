module Her
  module Middleware
    # This middleware treat the received first-level JSON structure as the resource data.
    class PaginationParseJSON < ParseJSON

      # Parse the response body
      #
      # @param [String] body The response body
      # @return [Mixed] the parsed response
      # @private
      def parse(body, header)
        json = parse_json(body)
        errors = json.delete(:errors) || {}
        metadata = json.delete(:metadata) || {}
        pagination = {
          total_count: header["x-total"].to_i,
          per_page:    header["x-per-page"].to_i,
          page:        header["x-page"].to_i,
          offset:      header['x-offset'].to_i
        }
        {
          data: json,
          errors: errors,
          metadata: metadata,
          pagination: pagination
        }
      end

      # This method is triggered when the response has been received. It modifies
      # the value of `env[:body]`.
      #
      # @param [Hash] env The response environment
      # @private
      def on_complete(env)
        env[:body] = case env[:status]
                     when 204
                       parse('{}')
                     else
                       parse(env[:body], env[:response_headers])
                     end
      end

      private

      # Returns a response header value.
      #
      # @param [String] name of the header attribute
      # @return [String] the response header value
      def header(haders, name)
        headers[name]
      end
    end
  end
end