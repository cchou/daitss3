require 'spec_helper'

describe "Mains" do
  describe "Home page" do
    it "should have the content 'Home'" do
      get root_path
      response.status.should be(200)
    end
  end
  
 describe "Help page" do
    it "should have the content 'Help'" do
      visit '/help'
      page.should have_content('Help')
    end

   it "should have the right title" do
      visit '/help'
      page.should have_selector('title', :text => "Help")
    end    
  end  
end