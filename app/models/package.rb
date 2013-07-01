class Package 
  include DataMapper::Resource

  property :id, String, :key => true
  property :uri, String, :unique => true, :required => true

  belongs_to :project
end
