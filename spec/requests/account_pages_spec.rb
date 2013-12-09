require 'spec_helper'

describe "AccountPages" do
  subject { page }

    describe "index" do
      before { visit accounts_path }
      
      it { should have_content('Admin->Accounts') }
      it "should list each account" do
        Account.user_accounts.each do |account|
          expect(page).to have_selector('td', text: account.id)
        end
      end      

    end

    # describe "create a new account" do
    #     let(:account) { FactoryGirl.create(:account) }
    # 
    #     before do
    #       visit new_account_path 
    #       fill_in "id", with: account.id
    #       fill_in "description", with: account.description
    #       fill_in "report_email", with: account.report_email
    #       click_button "Create Account"
    #     end
    #      
    # it { should have_selector('p.notice') }
    # end

end
