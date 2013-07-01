require 'spec_helper'

describe "Mains" do
  describe "GET /mains" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get mains_path
      response.status.should be(200)
    end
  end
  
  describe "Home page" do

  it "should have the content 'Home'" do
    visit '/main/home'
    page.should have_content('Home')
  end
  
  it "should have the content 'Help'" do
    visit '/main/help'
    page.should have_content('Help')
  end  
end
end