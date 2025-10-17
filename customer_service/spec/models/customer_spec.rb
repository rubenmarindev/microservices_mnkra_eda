require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address) }
  it { should validate_numericality_of(:orders_count).is_greater_than_or_equal_to(0).only_integer }

  it 'initializes orders_count to 0 by default' do
    customer = Customer.create(name: 'Test', address: 'Test Address')
    expect(customer.orders_count).to eq(0)
  end
end
