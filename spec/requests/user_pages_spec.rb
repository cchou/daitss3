require 'spec_helper'

describe "UserPages" do
  subject { page }

      describe "index" do
        let(:user) { FactoryGirl.create(:user) }

        # need to sign in before listing users due to the before_filter
        before do
          visit signin_path
          fill_in "id", with: user.id
          fill_in "auth_key", with: user.auth_key
          click_button "Sign in"
          visit users_path 
        end
        # ensure it's on the user listing page
        it { should have_content('Admin->Users') }
        it "should list each user" do
          User.all do |usr|
            expect(page).to have_selector('td', text: usr.id)
          end       
        end
     end
     
     describe "create a new user" do
       before do
         visit new_user_path 
         fill_in "Id", with: "doe"
         fill_in "Description", with: "Dummy User"       
         select('UF', :from => 'user_account_id')
         fill_in "user_first_name", with: "Jane"       
         fill_in "user_last_name", with: "Doe"       
         fill_in "Email", with: "doe@flvc.org"       
         fill_in "user_auth_key", with: "1111"       
         fill_in "Phone", with: "0000000"       
         fill_in "Address", with: "1 main street USA"       
         
         click_button "Create my account"        
       end
       it { should have_selector('div.alert.alert-success', text: 'Welcome to the Florida Digital Archive!') }
     end
end
