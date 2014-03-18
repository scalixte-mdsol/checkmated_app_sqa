# coding: utf-8
# Used to populate the mccadmin database tables on both a development environment
# and a Jenkins (sandbox, validation, etc) environment
require 'seeding_helper'
class SeedDatabase
  extend SeedingHelper
  extend EuresourceHelper
  include UUIDHelper

  def self.seed
    delete_all_table_records
    indications
    studies
    users
    sites
    authorizations
  end

  # Get all indications from References
  def self.indications
    # TODO translations and order
    # TODO possibly seed indication data outside MCCAdmin
    IndicationAggregate.delete_all
    @indications = Euresource::Indication.get(:all).per(ALL_COUNT) # TODO cap limit workaround
    @indications.each_with_index do |ind, i|
      %w[eng jpn].each do |locale|
        IndicationAggregate.create(uuid: ind.uuid, short_desc: ind.short_desc, order: i, language: locale)
      end
    end
  end

  private

  # Delete all of mccadmin's database tables that pertain to clinical objects, except Indications
  def self.delete_all_table_records
    [UserAggregate, StudyAggregate, AuthorizationAggregate, SiteAggregate].each do |table|
      table.send(:delete_all)
    end
  end

  # Get all studies from Plinth
  def self.studies
    studies = get_all('studies', {client_division_uuid: DEV_CLIENT_DIVISION_UUID}) # TODO cap limit workaround
    studies.each do |study|
      StudyAggregate.create_or_update_local(study)
    end
  end

  # Get all users from iMedidata that were created via seed_euresource.rb
  def self.users
    reset_user_counter
    seed_user(DEV_USER_UUID)
    while seed_user(generate_new_user_uuid) do
    end
  end

  # Attempts to seed a single user in User Aggregate DB; returns success Boolean.
  def self.seed_user(uuid)
    user = Euresource::User.get(uuid)
    UserAggregate.create_or_update_local(user)
    true
  rescue Exception => e
    false
  end

  # Get all role assignments from Dalton pertaining the users that were created via seed_euresource.rb
  def self.authorizations

    # client division auth
    AuthorizationAggregate.post({
      operator_uri: Mdsol::URI.generate(DEV_USER_UUID, resource: :users).to_s,
      operable_uri: Mdsol::URI.generate(DEV_CLIENT_DIVISION_UUID, resource: :client_divisions).to_s,
      role_uri: Mdsol::URI.generate(DEV_ROLE_UUID, resource: :configuration_type_roles).to_s
    })

    # other auths
    begin
      reset_user_counter
      while true do
        user = Euresource::User.get(generate_new_user_uuid)
        role_assignments = Euresource::RoleAssignment.get(:all, params: {operator_uri: user.mdsol_uri.to_s})
        role_assignments.each do |eu_auth|
          AuthorizationAggregate.create_or_update_local(eu_auth)
        end
      end
    rescue Euresource::ResourceNotFound # a user is not found
      # break out of loop
    end
  end

  # Get all study environment sites from Plinth
  def self.sites
    study_environment_sites = get_all('study_environment_sites') # TODO cap limit workaround
    study_environment_sites.each do |study_env_site|
      SiteAggregate.create_or_update_local(study_env_site)
    end
  end
end
