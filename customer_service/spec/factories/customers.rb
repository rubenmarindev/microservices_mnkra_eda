FactoryBot.define do
  factory :customer do
    name { "John Doe" }
    address { "123 Main St, Anytown, USA" }
    orders_count { 0 }
  end
end
