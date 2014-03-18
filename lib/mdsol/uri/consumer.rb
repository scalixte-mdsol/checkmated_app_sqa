module Mdsol::URI::Consumer

  def uuid_for(uri)
    Mdsol::URI.parse(uri).uuid
  end
end
