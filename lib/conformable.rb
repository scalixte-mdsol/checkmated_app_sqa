# consider putting this in an initializer for performance optimization
module Conformable
  module Json
    # Limit json output to exactly what the api document specifies.
    # Allow dynamically generated attributes to be included through methods.
    def as_json(options = {})
      api_config = YAML.load_file('apis/api_document_v1.yml')
      schema_properties = api_config["schemas"][self.class.to_s]["properties"].keys
      options.merge!(:only => schema_properties, :methods => schema_properties)
      super(options)
    end
  end
end