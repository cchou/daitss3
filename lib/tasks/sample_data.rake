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

    program.save or raise "cannot save system program"

    program = Program.create(:id => D1_PROGRAM_ID,
                          :description => "daitss 1 software agent",
                          :account => a)

    program.save or raise "cannot save daitss 1 program"

    operator = Operator.create(:id => ROOT_OPERATOR_ID,
                            :description => "default operator account",
                            :account => a,
                            auth_key: ROOT_OPERATOR_ID)   
                           
  end
  
  desc "Fill database with sample data"
  task populate: :environment do          
     password  = "password"
     Account.create(id: "UF", description: "UF", report_email: "report@uf.edu")
     Account.create(id: "USF", description: "USF", report_email: "report@usf.edu")
     Account.create(id: "UCF", description: "UCF", report_email: "report@ucf.edu")

    50.times do |n|
      user = User.create(id: Faker::Name.name, 
                   first_name: Faker::Name.first_name, 
                   last_name: Faker::Name.last_name,
                   email: Faker::Internet.email, 
                   auth_key: password,
                   phone: Faker::PhoneNumber.phone_number,
                   address: Faker::Address.street_address,
                   account_id: "UF")
    end
    50.times do |n|
      user = User.create(id: Faker::Name.name, 
                   first_name: Faker::Name.first_name, 
                   last_name: Faker::Name.last_name,
                   email: Faker::Internet.email, 
                   auth_key: password,
                   phone: Faker::PhoneNumber.phone_number,
                   address: Faker::Address.street_address,
                   account_id: "USF")                      
    end
  end
  
  # run this db:upgrade script after db:autoupgrade to create new columns
  desc "upgrade existing daitss2 database"
  task upgrade: :environment do
#    User.all.each {|u| u.update(:remember_token => u.new_remember_token)}
# execute(update agents set type = 'Program' where type = 'Daitss::Program');
# execute(update agents set type = 'User' where type = 'Daitss::User');
# execute(update agents set type = 'Operator' where type = 'Daitss:Operator');
  end
end