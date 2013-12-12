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

  describe "create a new account" do
    before do
      visit new_account_path 
      fill_in "Id", with: "ACT"
      fill_in "Description", with: "account"
      fill_in "Report email", with: "report@fda.edu"
      click_button "Create Account"        
    end
    it { should have_selector('p', text: 'Account was successfully created.') }
  end

  describe "delete an account" do
    before do
      visit accounts_path
    end
    
    it { should have_link('Destroy', href: accounts_path+'/ACT') }
    it "should be able to delete an account" do
      expect do
        #click_link('Destroy', href: accounts_path+'/ACT')
        page.find(:xpath, "//a[@href='#{accounts_path}/ACT']").click
      end.to change(Account, :count).by(-1)
    end
    it { should_not have_link('Destroy', href: accounts_path+'/ACT') }
  end
end
