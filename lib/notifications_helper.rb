# module for handling Archon subscribing
module NotificationsHelper

  # subscribe to resources
  def subscribe(app_uuid, subscription_endpoint, resources)
    # TODO: need to make paginated calls but cannot: Archon appears not to have pagination in their api doc
    all_subscriptions = Euresource::Subscriptions.get(:all)

    # for each resource we want notifications, check if topic exists
    resources.each do |name|
      begin
        hub_link = Euresource.class_for_resource(name).get(:all).per(1).last_result.headers['hub']
        topic_uuid = URI.parse(hub_link).path.split('/')[3]
      rescue StandardError => e
        log_and_raise("Error no hub: #{e.class.name}: #{e.message}")
      end

      # delete existing subscription on this topic and create new one
      all_subscriptions.each do |sub|
        if sub.attributes['topic_uuid'] == topic_uuid && sub.attributes['app_uuid'] == app_uuid
          Rails.logger.info("Deleting subscription: #{topic_uuid}")
          Euresource::Subscription.get(uuid: sub.uuid).delete
        end
      end
      begin
        Euresource::Topic.invoke!(:subscribe, {uuid: topic_uuid}, {
          :message_endpoint => subscription_endpoint,
          :subscription_type => 'https'
        })
        Rails.logger.info("Subscribed to topic: #{topic_uuid}")
      rescue StandardError => e
        log_and_raise("Subscription failed for topic #{topic_uuid}: #{e.class.name}: #{e.message}")
      end
    end
  end

  def log_and_raise(msg, level = :error)
    Rails.logger.send(level, msg)
    raise msg
  end
end
