FactoryGirl.define do
  factory :user do
    id     "Michael Hartl"
    auth_key "foobar"
    first_name "Michael"
    last_name "Hartl"
    email    "michael@example.com"
  end
end