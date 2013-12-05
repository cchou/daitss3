require 'spec_helper'

describe User do
  before do
    @user = User.new(id: "Example User", auth_key:"pw", first_name: "Example ", last_name: "User", email: "user@example.com")
  end

  subject { @user }

  it { should respond_to(:id) }
  it { should respond_to(:auth_key) }  
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }  
  it { should respond_to(:email) }  

  it { should be_valid }

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

end