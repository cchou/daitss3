require 'spec_helper'

describe "ProjectPages" do
  subject { page }

  describe "index" do
    before { visit projects_path }

    it { should have_content('Admin->Projects') }
    it "should list each project" do
      Project.user_projects do |prj|
        expect(page).to have_selector('td', text: prj.id)
      end
    end 
  end

  describe "create a new project" do
     before do
       visit new_project_path 
       fill_in "Id", with: "PRJ"
       fill_in "Description", with: "project"       
       #find("Account").select("FDA")
       select('UF', :from => 'project_account_id')
       click_button "Save changes"        
     end
     it { should have_selector('div.alert.alert-success', text: 'Project created') }
   end
  
   describe "delete an project" do
     before do
       visit projects_path
     end
     it { should have_link('Destroy', href: projects_path+'/PRJ?account_id=UF') }    
     it "should be able to delete an project" do
       expect do
         page.find(:xpath, "//a[@href='#{projects_path}/PRJ?account_id=UF']").click
       end.to change(Project, :count).by(-1)
     end
     it { should_not have_link('Destroy', href:projects_path+'/PRJ?account_id=UF') }
   end
end
