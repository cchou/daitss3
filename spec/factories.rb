FactoryGirl.define do
  factory :user do
    id            "daitss"
    auth_key      "daitss"
    first_name    "User"
    last_name     "Name"
    email         "user@example.com"
  end
  
  factory :account do
    id            "ACT5"
    description   "Account"
    report_email  "fda@example.com"
  end
  
  factory :project do
    id            "PRJ1"
    descrption    "Project"
    account_id    "ACT1"  
  end

end