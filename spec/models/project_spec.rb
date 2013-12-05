require 'spec_helper'

describe Project do
  before do
    @project = Project.new(id: "FDA", description:"", account_id: "FDA")
  end

  subject { @project }

  it { should respond_to(:id) }
  it { should respond_to(:description) }  
  it { should respond_to(:account_id) }

  it { should be_valid }

end