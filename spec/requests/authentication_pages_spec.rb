require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
    describe "signin page" do
      before { visit signin_path }

      describe "with invalid information" do
        before { click_button "Sign in" }

        it { should have_selector('title', text: 'Sign in') }
        it { should have_selector('div.alert.alert-error', text: 'Invalid') }
      end

      describe "with valid information" do
        let(:user) { FactoryGirl.create(:user) }

        before do
          visit signin_path
          fill_in "id", with: user.id
          fill_in "auth_key", with: user.auth_key
          click_button "Sign in"
        end

#      it { should have_title('Submit Packages') }
       it { should have_content('Packages->Submit') }
    end
  end

end
