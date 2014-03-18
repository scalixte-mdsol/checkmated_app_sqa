# module to aid with working with request parameters
module ParamsHelper
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    # Populate hash from request parameter value that has the format: "key1:value2;key2:value2;..."
    def get_hash_from_param(str)
      Hash[str.split(';').map { |pair| pair.split(':') }]
    end
  end
end
