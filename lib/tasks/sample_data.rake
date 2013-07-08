namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do      
     password  = "password"
     account = "UF"      
     user = User.create(id: "daitss", 
                   first_name: "daitss", 
                   last_name: "daitss",
                   email: Faker::Internet.email, 
                   auth_key: password,
                   phone: Faker::PhoneNumber.phone_number,
                   address: Faker::Address.street_address,
                   is_admin_contact: true,
                   is_tech_contact: true,
                   account_id: account)       
    100.times do |n|
 
      
      user = User.create(id: Faker::Name.name, 
                   first_name: Faker::Name.first_name, 
                   last_name: Faker::Name.last_name,
                   email: Faker::Internet.email, 
                   auth_key: password,
                   phone: Faker::PhoneNumber.phone_number,
                   address: Faker::Address.street_address,
                   account_id: account)
      # puts user.inspect
      # puts user.saved?    
    end
  end
end