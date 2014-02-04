
class Project
  include DataMapper::Resource

  property :id, String, :key => true
  property :description, Text

  property :account_id, String, :key => true

  has 0..n, :packages

  belongs_to :account, :key => true
  
 def to_param
    id
   # "#{id}/#{account_id}"
  end
  
  # retrieve the list of user accounts, excluding the "SYSTEM" - system account used by DAITSS program
  def self.user_projects
    Project.all - Project.all(:account_id => "SYSTEM")
  end    
end
