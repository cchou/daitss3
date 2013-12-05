require 'spec_helper'

describe Account do
  before do
    @account = Account.new(id: "FDA", description:"", report_email: " ")
  end

  subject { @account }

  it { should respond_to(:id) }
  it { should respond_to(:description) }  
  it { should respond_to(:report_email) }

  it { should be_valid }

end