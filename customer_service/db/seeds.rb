# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# customer_service/db/seeds.rb
Customer.find_or_create_by!(id: 1, name: 'Ozzy Ossbourne', address: 'Evergreen Av 123', orders_count: 0)
Customer.find_or_create_by!(id: 2, name: 'Roni James Dio', address: 'Fake Av 123', orders_count: 0)
Customer.find_or_create_by!(id: 3, name: 'Tony Martin', address: 'Baker Street 123', orders_count: 0)
