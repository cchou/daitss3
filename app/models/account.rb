#require 'dm-core'
#require 'dm-constraints'
#require 'dm-validations'

class Account
  include DataMapper::Resource

  property :id, String, :key => true
  property :description, Text
  property :report_email, String

  has 1..n, :projects, :constraint => :destroy
  has n, :agents

  def default_project
    p = self.projects.first :id => Daitss::Archive::DEFAULT_PROJECT_ID

    unless p
      p = Project.new :id => Daitss::Archive::DEFAULT_PROJECT_ID, :account => self
      p.save
    end

    return p
  end

  # retrieve the list of user accounts, excluding the "SYSTEM" - system account used by DAITSS program
  def self.user_accounts
    Account.all - Account.all(:id => "SYSTEM")
  end
end
