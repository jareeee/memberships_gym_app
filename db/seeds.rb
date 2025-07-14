# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding Gym Locations..."

locations = [
  {
    branch: 'LesGoGYM - Kelapa Gading',
    address: 'Jl. Boulevard Raya No. 1, Kelapa Gading, Jakarta Utara',
    qr_code_identifier: 'LGG-KLPG-001'
  },
  {
    branch: 'LesGoGYM - Senayan',
    address: 'Jl. Asia Afrika Pintu Satu Senayan, Jakarta Pusat',
    qr_code_identifier: 'LGG-SNYN-002'
  },
  {
    branch: 'LesGoGYM - Pondok Indah',
    address: 'Jl. Metro Pondok Indah Kav. IV, Jakarta Selatan',
    qr_code_identifier: 'LGG-PIND-003'
  }
]

locations.each do |location_attrs|
  GymLocation.create!(
    branch: location_attrs[:branch],
    address: location_attrs[:address],
    qr_code_identifier: location_attrs[:qr_code_identifier]
  )
end

puts "✅ Done Seeding Gym Locations."