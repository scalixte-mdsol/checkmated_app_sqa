require 'eureka_tools'
# This initializer uses eureka tools to fill our fake resources with
# fake data.  These resources were set up in config/initializers/eresource.rb.dice.
# This type of fakery can be useful during testing, if you are creating a service
# before all the backing services it will eventually integrate with exist.  All you need is an
# api document for the proposed service, and Eureka Tools can fake it for you.

if Rails.env == 'development' || Rails.env == 'production'
  # These UUIDs are from Dalton and they are used by Checkmate too
  # make studies
  [
      {"uuid" => "6555bd04-4795-11e1-81a0-00261824db2f", "name" => "Adravil" },
      {"uuid" => "ab1a11d6-4935-11e1-827e-00261824db2f", "name" => "Byphodine" },
      {"uuid" => "fbe7cf4a-4935-11e1-827e-00261824db2f", "name" => "Cordrazine" }
  ].each do |study_attrs|
    Euresource::Study.post(study_attrs)
  end
end
