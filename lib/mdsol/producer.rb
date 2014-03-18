module Mdsol::URI::Producer

  # This will construct a new Mdsol URI as a string
  # with a give URI prefix; e.g., "com:mdsol:studies"
  # If it is invalid, per our spec, this method will
  # raise an Mdsol::URI:InvalidComponentError
  def uri_from_prefix(uri_prefix, uuid)
    Mdsol::URI.new(*uri_prefix.split(":") << uuid).to_s
  end

  # Given a symbol representation a resource_type, and UUID
  # create a Mdsol::URI
  def uri_from_resource_type(resource_type, uuid)
    Mdsol::URI.generate(uuid, resource: resource_type)
  end
end
