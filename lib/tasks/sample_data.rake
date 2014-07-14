namespace :db do
  desc "Initialize database with default data"
  task init: :environment do    
    # id of system account
    SYSTEM_ACCOUNT_ID = 'SYSTEM'

    # id of system program
    SYSTEM_PROGRAM_ID = 'SYSTEM'

    # daitss1 id
    D1_PROGRAM_ID = 'DAITSS1'

    # id of default operator
    ROOT_OPERATOR_ID = 'daitss'

    # id of default projects
    DEFAULT_PROJECT_ID = 'default'
      
     # account
    a = Account.create(:id => SYSTEM_ACCOUNT_ID,
                    :description => 'account for system operations')

    p = Project.create(:id => DEFAULT_PROJECT_ID,
                    :description => 'default project for system operations',
                    :account => a)

    act = Account.create(:id => "ACT",
                    :description => 'sample account')

    prjd = Project.create(:id => 'default', :description => 'default project for sample account', :account => act)

    prj = Project.create(:id => "PRJ",
                    :description => 'sample project',
                    :account => act)

    # some agents
    program = Program.create(:id => SYSTEM_PROGRAM_ID,
                          :description => "daitss software agent",
                          :account => a)
    program.create_remember_token
    program.save or raise "cannot save system program, #{program.errors.full_messages}"

    program = Program.create(:id => D1_PROGRAM_ID,
                          :description => "daitss 1 software agent",
                          :account => a)
    program.create_remember_token
    program.save or raise "cannot save daitss 1 program"

    operator = Operator.create(:id => ROOT_OPERATOR_ID,
                            :description => "default operator account",
                            :account => a,
                            auth_key: ROOT_OPERATOR_ID)   
    operator.encrypt_auth(ROOT_OPERATOR_ID)
    operator.create_remember_token
    operator.save or raise "cannot save operator, #{program.errors.full_messages}"
                          
  end
  
  desc "Fill database with sample account and projects"
  task populate_act_prj: :environment do          
    # create sample accounts
    Account.create(id: "UF", description: "UF", report_email: "report@uf.edu")
    Account.create(id: "USF", description: "USF", report_email: "report@usf.edu")
    Account.create(id: "UCF", description: "UCF", report_email: "report@ucf.edu")
    Account.create(id: "FSU", description: "FSU", report_email: "report@fsu.edu")
    Account.create(id: "FAU", description: "FAU", report_email: "report@fau.edu")

    # create sample projects
    Project.create(id: "ETD", description: "Electronic Thesis Disertation", account_id: "UF")
    Project.create(id: "ETD", description: "Electronic Thesis Disertation", account_id: "USF")
    Project.create(id: "ETD", description: "Electronic Thesis Disertation", account_id: "UCF")
    Project.create(id: "ETD", description: "Electronic Thesis Disertation", account_id: "FSU")
    Project.create(id: "ETD", description: "Electronic Thesis Disertation", account_id: "FAU")
  end
  
  desc "Fill database with sample packages"
  task populate_packages: :environment do
    password  = "daitss"

    # create sample users, packages
    20.times do |n|
      user = User.create(id: Faker::Name.name, 
                   first_name: Faker::Name.first_name, 
                   last_name: Faker::Name.last_name,
                   email: Faker::Internet.email, 
                   auth_key: password,
                   phone: Faker::PhoneNumber.phone_number,
                   address: Faker::Address.street_address,
                   account_id: "UF")
      user.create_remember_token
      prj = Account.get("UF").projects.first("ETD")
      package = Package.new 
      package.sip = Sip.new :name => "UF"+rand(100000).to_s
      prj.packages << package      
      package.log 'submit', :notes => "N/A"      
      user.save or raise "cannot save user #{user.id}, #{user.errors.full_messages}"
      package.save or raise "cannot save package #{package.id}"       
    end
    
    20.times do |n|
      user = User.create(id: Faker::Name.name, 
                   first_name: Faker::Name.first_name, 
                   last_name: Faker::Name.last_name,
                   email: Faker::Internet.email, 
                   auth_key: password,
                   phone: Faker::PhoneNumber.phone_number,
                   address: Faker::Address.street_address,
                   account_id: "USF")  
      user.create_remember_token
      prj = Account.get("USF").projects.first("ETD")
      package = Package.new 
      package.sip = Sip.new :name => "USF"+rand(100000).to_s
      prj.packages << package      
      package.log 'submit', :notes => "N/A"      
      user.save or raise "cannot save user #{user.id}, #{user.errors.full_messages}"
      package.save or raise "cannot save package #{package.id}"
                                             
    end
    20.times do |n|
      user = User.create(id: Faker::Name.name, 
      first_name: Faker::Name.first_name, 
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email, 
      auth_key: password,
      phone: Faker::PhoneNumber.phone_number,
      address: Faker::Address.street_address,
      account_id: "UCF")
      user.create_remember_token
      prj = Account.get("UCF").projects.first("ETD")
      package = Package.new 
      package.sip = Sip.new :name => "UCF"+rand(100000).to_s
      prj.packages << package      
      package.log 'submit', :notes => "N/A"
      user.save or raise "cannot save user #{user.id}, #{user.errors.full_messages}"
      package.save or raise "cannot save package #{package.id}"                            
    end    
    
    20.times do |n|
      user = User.create(id: Faker::Name.name, 
      first_name: Faker::Name.first_name, 
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email, 
      auth_key: password,
      phone: Faker::PhoneNumber.phone_number,
      address: Faker::Address.street_address,
      account_id: "FSU")                      
      user.create_remember_token
      prj = Account.get("FSU").projects.first("ETD")
      package = Package.new 
      package.sip = Sip.new :name => "FSU"+rand(100000).to_s
      prj.packages << package      
      package.log 'submit', :notes => "N/A"
      user.save or raise "cannot save user #{user.id}, #{user.errors.full_messages}"
      package.save or raise "cannot save package #{package.id}"
    end    
    
    20.times do |n|
      user = User.create(id: Faker::Name.name, 
      first_name: Faker::Name.first_name, 
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email, 
      auth_key: password,
      phone: Faker::PhoneNumber.phone_number,
      address: Faker::Address.street_address,
      account_id: "FAU")    
      user.create_remember_token
      prj = Account.get("FAU").projects.first("ETD")
      package = Package.new 
      package.sip = Sip.new :name => "FAU"+rand(100000).to_s
      prj.packages << package      
      package.log 'submit', :notes => "N/A"      
      user.save or raise "cannot save user #{user.id}, #{user.errors.full_messages}"
      package.save or raise "cannot save package #{package.id}"                        
    end
  end
  
  # run this db:upgrade script after db:autoupgrade to create new columns
  desc "upgrade existing daitss2 database"
  task upgrade: :environment do
    #User.all.each {|u| u.update(:remember_token => u.new_remember_token)}
    # rake db:autoupgrade
    #execute("update agents set type = 'Program' where type = 'Daitss::Program'")
    #execute("update agents set type = 'User' where type = 'Daitss::User'")
    #execute("update agents set type = 'Operator' where type = 'Daitss::Operator'")
    #execute("update agents set type = 'Contact' where type = 'Daitss::Contact'")
  end
end