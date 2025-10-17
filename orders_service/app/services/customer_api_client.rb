class CustomerApiClient
  BASE_URL = ENV.fetch("CUSTOMER_SERVICE_URL", "http://127.0.0.1:3001/api/v1")

  def self.fetch_customer_details(customer_id)
    connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :json
      faraday.response :json, parser_options: { symbolize_names: true }
      faraday.adapter Faraday.default_adapter
    end

    response = connection.get("customers/#{customer_id}")

    if response.success?
      response.body
    else
      Rails.logger.error "OrderService: Failed to fetch customer details for ID #{customer_id}. Status: #{response.status}, Body: #{response.body}"
      nil
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "OrderService: Connection to CustomerService failed: #{e.message}"
    nil
  end
end
