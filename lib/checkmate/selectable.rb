module Checkmate
  module Selectable
    include Mdsol::URI::Producer

    # returns a string representation of the URI of the instance
    def uri_s
      uri.to_s
    end

    def uri
      params = self.class_eval("URI_PREFIX").split(':') << self.uuid || uuid
      @uri ||= Mdsol::URI.new(*params)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      include Mdsol::URI::Producer

      # Like Rails, a ActiveModel class fetches a collection, and
      # this class adds a method that will return a "collection" URI
      # for checkmate.  In checkmate, a collection URI ends in none
      # (kinda wierd)
      # Example: com:mdsol:products:none
      def uri_s
        uri_for_resource_s
      end

      # Method that returns the URI based on the class URI_PREFIX
      def uri_for_resource_s(uuid = "none")
        uri_from_prefix(self.class_eval("URI_PREFIX"), uuid)
      end
    end
  end
end
