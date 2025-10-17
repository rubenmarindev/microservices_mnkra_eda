# spec/factories/orders.rb

FactoryBot.define do
  # Debe coincidir exactamente con el nombre del modelo
  factory :order do
    # Define los atributos predeterminados aquí
    customer_id { 101 }
    product_name { 'Sample Product' }
    quantity { 2 }
    price { 49.99 }
    status { 'pending' }
  end
end
