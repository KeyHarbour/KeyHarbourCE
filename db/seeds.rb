# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Role.create(name: 'Owner') if Role.find_by(name: 'Owner').nil?
Role.create(name: 'Admin') if Role.find_by(name: 'Admin').nil?
Role.create(name: 'User') if Role.find_by(name: 'User').nil?
Role.create(name: 'Viewer') if Role.find_by(name: 'Viewer').nil?