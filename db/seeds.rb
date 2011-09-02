# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
roope = User.create(:email => "pankki@gmail.com", :password => Devise.friendly_token[0,20], :name => 'Roope Ankka')
jim = User.create(:email => "raynorhere@gmail.com", :password => Devise.friendly_token[0,20], :name => 'Jim Raynor') 

Transfer.create(:creditor => roope, :debtor => jim, :creator => jim, :amount => 100, :message => "boxer veto")