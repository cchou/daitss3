class Batch
  include DataMapper::Resource
  property :id, String, :key => true

  has n, :batch_assignments
  has n, :packages, :through => :batch_assignments
end

class BatchAssignment
  include DataMapper::Resource

  belongs_to :batch, :key => true
  belongs_to :package, :key => true
end