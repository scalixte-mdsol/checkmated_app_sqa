# module to aid with UUID work
module UUIDHelper
  def self.included(klass)
    klass.extend ClassMethods
  end

  # set the uuid in the current object
  def set_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end

  module ClassMethods
    # extract the UUID from the URI
    def get_uuid(uri)
      uri.split(':').last
    end
  end
end
