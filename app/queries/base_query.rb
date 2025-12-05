class BaseQuery
  def initialize(relation = nil)
    @relation = relation
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  private

  attr_reader :relation
end