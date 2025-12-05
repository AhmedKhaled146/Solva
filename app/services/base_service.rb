class BaseService
  attr_reader :errors

  def initialize
    @errors = []
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  def success?
    @errors.empty?
  end

  def failure?
    !success?
  end

  private

  def add_error(message)
    @errors << message
  end

  def handle_record_invalid(exception)
    add_error(exception.message)
    false
  end

  def handle_standard_error(exception)
    add_error("An unexpected error occurred: #{exception.message}")
    Rails.logger.error("#{self.class.name} Error: #{exception.full_message}")
    false
  end
end