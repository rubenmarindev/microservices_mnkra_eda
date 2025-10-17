# customer_service/spec/requests/api/v1/customers_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Customers', type: :request do
  let!(:customer) { create(:customer, id: 1, name: 'Dio', address: 'Evergreen 123', orders_count: 5) }
  let!(:non_existent_id) { 999 }

  describe 'GET /api/v1/customers/:id' do
    context 'when customer exists' do
      before { get api_v1_customer_path(customer.id) }

      it 'returns customer details' do
        expect(response).to have_http_status(:ok)
        expect(json['customer_id']).to eq(customer.id)
        expect(json['customer_name']).to eq('Dio')
        expect(json['address']).to eq('Evergreen 123')
        expect(json['orders_count']).to eq(5)
      end
    end

    context 'when customer does not exist' do
      before { get api_v1_customer_path(non_existent_id) }

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(json['error']).to eq('Customer not found')
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
