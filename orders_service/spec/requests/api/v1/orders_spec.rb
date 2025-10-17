# orders_service/spec/requests/api/v1/orders_spec.rb
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe 'Api::V1::Orders', type: :request do
  let(:customer_id) { 1 }
  let(:customer_details) { { customer_id: customer_id, customer_name: 'Test Customer', address: '123 Test St', orders_count: 0 } }

  before do
    stub_request(:get, "http://127.0.0.1:3001/api/v1/customers/#{customer_id}")
      .to_return(status: 200, body: customer_details.to_json, headers: { 'Content-Type' => 'application/json' })
    allow(RABBITMQ_CONNECTION).to receive(:create_channel).and_return(double('channel', topic: double('exchange', publish: true)))
    allow(EventPublishers::OrderPublisher).to receive(:publish_created)
  end

  describe 'POST /api/v1/orders' do
    context 'with valid parameters' do
      let(:valid_attributes) { { order: { customer_id: customer_id, product_name: 'Laptop', quantity: 1, price: 1200.00 } } }

      it 'creates a new Order' do
        expect {
          post api_v1_orders_path, params: valid_attributes, as: :json
        }.to change(Order, :count).by(1)
      end

      it 'returns a created status and order details' do
        post api_v1_orders_path, params: valid_attributes, as: :json
        expect(response).to have_http_status(:created)
        expect(json['order']['customer_id']).to eq(customer_id)
        expect(json['customer_details']['customer_name']).to eq('Test Customer')
      end

      it 'publishes an order.created event' do
        post api_v1_orders_path, params: valid_attributes, as: :json
        expect(EventPublishers::OrderPublisher).to have_received(:publish_created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { order: { customer_id: nil, product_name: '', quantity: 0, price: -100 } } }

      before do
        stub_request(:get, "http://127.0.0.1:3001/api/v1/customers/").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v2.14.0'
           }).
         to_return(status: 200, body: "", headers: {})
      end
      it 'does not create a new Order' do
        expect {
          post api_v1_orders_path, params: invalid_attributes, as: :json
        }.not_to change(Order, :count)
      end

      it 'returns an unprocessable entity status and errors' do
        post api_v1_orders_path, params: invalid_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Customer can't be blank")
      end
    end

    context 'when customer does not exist in CustomerService' do
      before do
        stub_request(:get, "http://localhost:3001/api/v1/customers/999")
          .to_return(status: 404, body: { error: "Customer not found" }.to_json, headers: { 'Content-Type' => 'application/json' })
        allow(CustomerApiClient).to receive(:fetch_customer_details).and_return(nil)
      end
      let(:attributes_with_invalid_customer) { { order: { customer_id: 999, product_name: 'Invalid', quantity: 1, price: 100 } } }

      it 'does not create a new Order' do
        expect {
          post api_v1_orders_path, params: attributes_with_invalid_customer, as: :json
        }.not_to change(Order, :count)
      end

      it 'returns an unprocessable entity status and error' do
        post api_v1_orders_path, params: attributes_with_invalid_customer, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Customer does not exist or CustomerService is unreachable")
      end
    end
  end

  describe 'GET /api/v1/orders' do
    let(:customer_id) { 1 }
    let!(:order1) { create(:order, customer_id: customer_id, product_name: 'Product A') }
    let!(:order2) { create(:order, customer_id: customer_id, product_name: 'Product B') }

    context 'when customer_id is present and has 2 orders' do
      before do
        #get api_v1_orders_path, params: { customer_id: customer_id }, as: :json
        get "/api/v1/orders/?customer_id=#{customer_id}", as: :json
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns both orders for the customer' do
        expect(json.size).to eq(2)
        expect(json.map { |o| o['id'] }).to match_array([order1.id, order2.id])
        expect(json.all? { |o| o['customer_id'] == customer_id }).to be true
      end
    end

    context 'with invalid customer_id' do
      before do
        #get api_v1_orders_path, params: { customer_id: 999 }, as: :json
        get "/api/v1/orders/?customer_id=999", as: :json
      end

      it 'returns no orders' do
        expect(response).to have_http_status(:ok)
        expect(json).to be_empty
      end
    end

    context 'without customer_id parameter' do
      before { get api_v1_orders_path, as: :json }

      it 'returns bad request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        expect(json['error']).to eq('customer_id parameter is required')
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
