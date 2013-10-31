require 'spec_helper'

describe "Mains" do
  
  describe "Home page" do
    it "should have the content 'Home'" do
      get root_path
      response.status.should be(200)
    end
  end
  
  subject { page }
  describe "Help page" do
    before { visit help_path}
    
    it { should have_content('Help') }
    it { should have_selector('title', :text => "Help") }
  end  
  
  # describe "About page" do
  #   it "should be a working url" do
  #     click_link "About"
  #     response.status.should be(200)
  #   end
  # end
  # 
  # describe "Contact page" do
  #  it "should be a working url" do
  #     click_link "Contact"
  #     response.status.should be(200)    
  #   end
  # end
end