module Dashboard
  # This service class gives a place to put business logic to assist generate pdf file
  class GeneratePdfPage
    # @overload call(referer, path, auth_token)
    # This method returns the resulting PDF data
    # @param [String] referer
    # @param [String] path URL of the page to convert
    # @param [String] auth token to get page access
    # @return [String] The resulting PDF data
    def self.call(referer, path, auth_token)
      origin = Addressable::URI.parse(referer)
      origin.path = path
      Grover.new(origin.to_s, cookies: [{ name: '_session_auth_token', value: auth_token, domain: origin.host }]).to_pdf
    end
  end
end
