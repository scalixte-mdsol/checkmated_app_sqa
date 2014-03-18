# coding: utf-8
# Used to populate objects in services (mocked or unmocked on both a development environment
# and a Jenkins (sandbox, validation, etc) environment
require 'seeding_helper'
class SeedEuresource
  extend SeedingHelper
  extend EuresourceHelper
  INDICATION_NAMES = ["Allergy", "Alzheimer Disease", "Anemia", "Brain Cancer", "Breast Cancer", "Food Studies",
    "Lupus", "Pneumonia", "Podiatry", "Polycythemia Vera", "Post-Surgical Pain", "Pulmonary, Other",
    "Renal Impairment", "Renal Impairment / Chronic Kidney Disease", "Restless Leg Syndrome", "Rheumatoid Arthritis",
    "Urology, Other", "Vaccines",
    "Abnormal Result of Cardiovascular Study: Ventricular/LV Function Myocardial Blood Flow"
  ]

  # Populate all Euresource objects in various services (i.e. Plinth, Dalton, etc.)
  def self.seed(num_studies)
    @total_num_studies = num_studies
    study_phases
    study_indications
    client_divisions
    config_types
    config_type_roles
    studies
    user_details
    role_assignments
    user_with_multiple_role_assignments
    sites
    site_assignments
    privileges
  end

  private

  # Checks if a resource is intentionally mocked (handled by Eureka Tools instead of the service that owns it)
  def self.resource_is_mocked?(resource_name)
    EurekaTools::ResourceMockerManager.resource_mockers.map do |klass|
      klass.name.split('::').last.underscore.to_sym
    end.include?(resource_name)
  end

  # Check if the 'Sole Client Division' exists, if not create it
  def self.client_divisions
    client_division_name = 'Sole Client Division'
    found_client_division = safe_fetch('ClientDivision', :all, params: {name: client_division_name}).try(:first)
    @client_division_uuid = if found_client_division
      found_client_division.uuid
    else
      attrs = {name: client_division_name, uuid: DEV_CLIENT_DIVISION_UUID}
      Euresource::ClientDivision.post(attrs, method: 'create').uuid
    end
  end

  # Phases can be mocked since we should never seed references
  def self.study_phases
    if resource_is_mocked?(:phase)
      ui_phases = %w(I I_II II II_III IIa IIb III IIIa IIIb IV V)
      ui_phases.each do |phase_name|
        Euresource::Phase.post({name: "Phase #{phase_name}", category: "ui"})
      end
      md_phases = ["Pre-Clinical", "Pilot Clincal Trial", "Pivotal Clinal Trials", "Post Marketing Surveillance"]
      md_phases.each do |phase_name|
        Euresource::Phase.post({name: "Phase #{phase_name}", category: "medical_device"})
      end
    end
    @phase_uuids = Euresource::Phase.get(:all).map { |p| p.uuid }
  end

  # Indications can be mocked since we should never seed indications
  def self.study_indications
    if resource_is_mocked?(:indication)
      INDICATION_NAMES.each_with_index do |name, i|
        attrs = {
          code: "code",
          short_desc: name,
          long_desc: "long desc",
          indication_group: "ig",
          therapeutic_area: "ta",
          uuid: "b0daa7a0-29eb-11e3-8224-0800200c9#{'%03d' % i}"
        }
        Euresource::Indication.post(attrs)
      end
    end
    @indication_uuids = Euresource::Indication.get(:all).map { |i| i.uuid }
  end

  # Get all configuration types that exist for the client division; if the ones we want don't exist, create them
  def self.config_types
    existing_config_types = Euresource::ConfigurationType.get(:all, params: {client_division_uuid: @client_division_uuid})
    @config_type_uuids = []
    wanted_config_types = ['Late Phase', 'CRO Internal', 'CRO Customer A', 'Early Phase']
    wanted_config_types.each do |name|
      existing_config_type = existing_config_types.find { |existing_cf| existing_cf.name == name}
      uuid = if existing_config_type
        existing_config_type.uuid
      else
        ct = {client_division_uuid: @client_division_uuid, name: name}
        Euresource::ConfigurationType.post(ct, method: 'create').uuid
      end
      @config_type_uuids << uuid
    end
  end

  # Static set of roles that may be assigned to a configuration type
  def self.roles
    [{
       name: 'Clinical Ops',
       role_category_oid: 'Clinical Ops',
       permissions: [{protected_resource_type: 'studies', operation: 'unlock'}]
     },
     {
       name: 'Data Management',
       role_category_oid: 'Data Management',
       permissions: [{protected_resource_type: 'studies', operation: 'unlock'}, {"protected_resource_type"=>"studies", "operation"=>"lock"}]
     },
     {
       name: 'Drug Safety',
       role_category_oid: 'Drug Safety',
       permissions: [{"protected_resource_type"=>"studies", "operation"=>"lock"}]
     },
     {
       name: 'Medical Writers',
       role_category_oid: 'Medical Writers',
       permissions: [{"protected_resource_type"=>"users", "operation"=>"lock"}, {"protected_resource_type"=>"studies", "operation"=>"lock"}]
     },
     {
       name: 'Site',
       role_category_oid: 'Site',
       permissions: [{"protected_resource_type"=>"users", "operation"=>"lock"}, {"protected_resource_type"=>"studies", "operation"=>"lock"}]
     },
     {
       name: 'Principal Investigator',
       role_category_oid: 'Site',
       permissions: [{ "protected_resource_type" => "users", "operation" => "lock" }, { "protected_resource_type" => "studies", "operation" => "lock" }]
     }]
  end

  # For each configuration type for the client division, create additional roles using a subset of the entire roles set
  def self.config_type_roles
    @config_type_uuids.each_with_index do |config_type_uuid, i|
      for j in 0..2
        role = roles[(i + j) % roles.size]
        unless @checkmate_role_already_created
          role[:uuid] = DEV_ROLE_UUID
          @checkmate_role_already_created = true
        end
        create_configuration_type_role(role.merge(configuration_type_uuid: config_type_uuid))
      end
    end
  end

  # Create studies in Plinth
  def self.studies
    (checkmated_studies + named_study_attrs + anonymous_study_attrs).each do |attrs|
      params = {protocol_id: attrs[:protocol_id], client_division_uuid: attrs[:client_division_uuid]}
      if Euresource::Study.get(:all, params: params).total_count == 0
        Euresource::Study.post(attrs, method: 'create')
      end
    end
  end

  # create for the purpose of a local checkmated environment
  def self.checkmated_studies
    if resource_is_mocked?(:study)
      [
        {protocol_id: 'Adravil', uuid: '6555bd04-4795-11e1-81a0-00261824db2f'},
        {protocol_id: 'Byphodine', uuid: 'ab1a11d6-4935-11e1-827e-00261824db2f'},
        {protocol_id: 'Cordrazine', uuid: 'fbe7cf4a-4935-11e1-827e-00261824db2f'}
      ].each_with_index do |attrs, i|
        attrs.merge!(
          name: attrs[:protocol_id],
          phase_uuid: @phase_uuids[i % @phase_uuids.size],
          primary_indication_uuid: @indication_uuids[i % @indication_uuids.size],
          configuration_type_uuid: @config_type_uuids[i % @config_type_uuids.size],
          test_study: false,
          client_division_uuid: @client_division_uuid)
      end
    else
      []
    end
  end

  # Studies that have static names
  def self.named_study_attrs
    @named_study_attrs = [
      'CLAR-09007', 'RLY5016-205', 'EN3409-307', 'ISTO NEO-01-09-01', 'NP25620', 'MM-121-04-02-08', 'AGS-22M6E-11-1',
      'ML25753', 'WV25651', 'CC-223-ST-001 B', 'MoreThan50Charactersqwertyuiopasdfghjklm12345678901'
    ].each_with_index.map do |pid, i|
      {
        client_division_uuid: @client_division_uuid,
        protocol_id: pid,
        name: pid,
        phase_uuid: @phase_uuids[i % @phase_uuids.size],
        primary_indication_uuid: @indication_uuids[i % @indication_uuids.size],
        configuration_type_uuid: @config_type_uuids[i % @config_type_uuids.size],
        test_study: false
      }
    end
  end

  # Studies with numbered names
  def self.anonymous_study_attrs
    @anonymous_study_attrs = []
    (@total_num_studies - @named_study_attrs.length).times do |i|
      @anonymous_study_attrs << {
        client_division_uuid: @client_division_uuid,
        name: "TestStudy_#{i}",
        protocol_id: "ProtocolID_#{i}",
        phase_uuid: @phase_uuids[i % @phase_uuids.size],
        primary_indication_uuid: @indication_uuids[i % @indication_uuids.size],
        configuration_type_uuid: @config_type_uuids[i % @config_type_uuids.size],
        test_study: false
      }
    end
    @anonymous_study_attrs
  end

  # Since we are still mocking users, pass a UUID on creation
  # TODO once integrated, must create users according to the contract
  def self.user_details
    @user_uuids = []

    create_user(uuid: DEV_USER_UUID, email: 'adminuser@example.com', first_name: 'Admin', last_name: 'User', telephone: '0')

    usr_params = {
      uuid: generate_new_user_uuid,
      first_name: '茂樹',
      last_name: '藤本',
      email: "fujimoto_shigeki@mdsol.com",
      telephone: "03-8394-2203",
    }
    create_user(usr_params)

    (1..25).each do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = Faker::Internet.email(first_name[0] + last_name)
      usr_params = {
        uuid: generate_new_user_uuid,
        first_name: first_name,
        last_name: last_name,
        email: email,
        login: email,
        address_line_1: Faker::Address.street_address,
        address_line_2: Faker::Address.secondary_address,
        city: Faker::Address.city,
        state: Faker::Address.state,
        postal_code: Faker::Address.zip_code,
        country: %w(USA CAN FRA).sample,
        institution: Faker::Company.name,
        title: ['Data Manager', 'Logger'].sample,
        department: ['Healthy Living', 'Cancer Treatment'].sample,
        locale: %w(English Japanese).sample,
        time_zone: ['Eastern Standard Time', 'Pacific Standard Time'].sample,
        telephone: Faker::PhoneNumber.phone_number,
      }
      create_user(usr_params)
    end
  end

  # Get config type roles that are used to create role assignments
  def self.get_config_type_roles(config_type_uuid)
    role_params = {params: {configuration_type_uuid: config_type_uuid}}
    Euresource::ConfigurationTypeRole.get(:all, role_params)
  end

  def self.role_assignments
    studies = Euresource::Study.get(:all, params: {client_division_uuid: @client_division_uuid})
    return if studies.empty?
    @user_uuids.each_with_index do |user_uuid, i|
      study = studies[i % studies.count]
      study_envs = Euresource::StudyEnvironment.get(:all, params: {study_uuid: study.uuid})
      roles = get_config_type_roles(study.configuration_type_uuid)
      attrs = {
        operator_uri: Euresource::User.get(user_uuid).mdsol_uri.to_s,
        operable_uri: study_envs[i % study_envs.count].mdsol_uri.to_s,
        role_uri: roles[i % roles.size].mdsol_uri.to_s,
      }
      create_role_assignment(attrs)
    end
  end

  # Just for Reveal until we can actually edit role assignments.
  def self.user_with_multiple_role_assignments
    return unless (study = Euresource::Study.get(:all, params: {client_division_uuid: @client_division_uuid}).first)
    users = (1..10).map do |i|
      usr_attrs = {
        uuid: generate_new_user_uuid,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        telephone: i
      }
      usr_attrs[:email] = Faker::Internet.email(usr_attrs[:first_name][0] + usr_attrs[:last_name])
      create_user(usr_attrs)
    end
    users.each do |user|
      roles = get_config_type_roles(study.configuration_type_uuid)
      roles.each_with_index do |role, i|
        next if i % 2 == 0
        attrs = {
          operator_uri: user.mdsol_uri.to_s,
          operable_uri: study.mdsol_uri.to_s,
          role_uri: role.mdsol_uri.to_s,
        }
        create_role_assignment(attrs)
      end
    end
  end

  # Create study environment sites from scratch, and load them into mccadmin's local database tables
  def self.sites
    study = Euresource::Study.get(:all, params: {client_division_uuid: @client_division_uuid}).first
    study_envs = Euresource::StudyEnvironment.get(:all, params: {study_uuid: study.uuid})
    (1..25).each do |counter|
      site_params = {
        study_uuid: study.uuid,
        client_division_uuid: study.client_division_uuid,
        study_environment_uuid: study_envs[counter % study_envs.total_count].uuid,
        site_number: "%03d" % counter,
        client_division_site_number: "201-%03d" % counter,
        name: Faker::Company.name,
        principal_investigator_user_uuid: @user_uuids[1],
        main_address: {
          address_1: Faker::Address.street_address,
          address_2: Faker::Address.secondary_address,
          city: Faker::Address.city,
          state: %w(NJ NY CT).sample,
          country: 'USA',
          postal_code: Faker::Address.zip_code
        }
      }
      create_study_environment_site(site_params)
    end
  end

  def self.site_assignments
    study = Euresource::Study.get(:all, params: {client_division_uuid: @client_division_uuid}).first
    study_envs = Euresource::StudyEnvironment.get(:all, params: {study_uuid: study.uuid})
    roles = get_config_type_roles(study.configuration_type_uuid)
    sites = Euresource::StudyEnvironmentSite.get(:all, params: {study_environment_uuid: study_envs[0].uuid})
    @user_uuids.each_with_index do |user_uuid, i|
      attrs = {
          operator_uri: Euresource::User.get(user_uuid).mdsol_uri.to_s,
          operable_uri: sites[i % sites.count].mdsol_uri.to_s,
          role_uri: roles[i % roles.size].mdsol_uri.to_s,
      }
      create_role_assignment(attrs)
    end
  end

  # TODO refactor below methods to share code

  # If the user does not already exist, create it
  def self.create_user(attrs)
    user = begin
      Euresource::User.get(attrs[:uuid])
    rescue Euresource::ResourceNotFound
      Euresource::User.post(attrs, method: 'create')
    end
    @user_uuids << user.uuid
    user
  end

  # If the study environment site does not already exist, create it along with its needed parent objects
  def self.create_study_environment_site(attrs)
    study_env_site_params = {params: {study_environment_uuid: attrs[:study_environment_uuid]}}
    unless Euresource::StudyEnvironmentSite.get(:all, study_env_site_params).find { |site| site.site_number == attrs[:site_number] }
      SiteAggregate.cascade_create_site(attrs, 'create')
    end
  end

  # If a configuration type role does not already exist, create it
  def self.create_configuration_type_role(attrs)
    params = {params: {configuration_type_uuid: attrs[:configuration_type_uuid]}}
    unless Euresource::ConfigurationTypeRole.get(:all, params).find { |ctr| ctr.name == attrs[:name]}
      Euresource::ConfigurationTypeRole.post(attrs)
    end
  end

  # If the role assignment does not already exist, create it
  def self.create_role_assignment(attrs)
    params = {params: {operator_uri: attrs[:operator_uri]}}
    unless Euresource::RoleAssignment.get(:all, params).find { |ra| ra.operable_uri == attrs[:operable_uri] && ra.role_uri == attrs[:role_uri] }
      Euresource::RoleAssignment.post(attrs, method: 'create')
    end
  end

  def self.privileges
    if resource_is_mocked?(:privilege)
      # Default user can create studies
      Euresource::Privilege.post({
        operator_uri: Mdsol::URI.generate(DEV_USER_UUID, resource: :users).to_s,
        operable_uri: Mdsol::URI.generate(@client_division_uuid, resource: :client_divisions).to_s,
        operation: 'create_studies',
        blocked: false
      })
    end
  end

  # Methods for creating remote objects, mainly for testing Archon notifications.

  # Creates a single Role Assignment with for a specific study and user parameter.
  # the role is selected randomly from existing config type roles for the study.
  def self.create_role_assignment_from_study_and_user(study_uuid, user_uuid, study_env_oid)
    study_env_uuid = Euresource::StudyEnvironment.get(:all, params: {study_uuid: study_uuid}).find do |se|
      se.environment_oid == study_env_oid
    end.uuid
    config_type_uuid = Euresource::Study.get(study_uuid).configuration_type_uuid
    roles = Euresource::ConfigurationTypeRole.get(:all, params: {configuration_type_uuid: config_type_uuid})
    role_uuid = roles.first.uuid
    attrs = {
      operator_uri: Mdsol::URI.generate(user_uuid, resource: :users).to_s,
      operable_uri: Mdsol::URI.generate(study_env_uuid, resource: :study_environments).to_s,
      role_uri: Mdsol::URI.generate(role_uuid, resource: :configuration_type_roles).to_s
    }
    create_role_assignment(attrs)
  end

  # Creates a single Study Environment Site for a given study and environment. The site is created from a randomly
  # selected client division site within the same client division as the study.
  def self.create_study_environment_site_from_study(study_uuid, study_env_oid)
    study = Study.get(study_uuid)
    study_env = Euresource::StudyEnvironment.get(:all, params: {study_uuid: study.uuid}).find do |se|
      se.environment_oid == study_env_oid
    end
    cd_sites = Euresource::ClientDivisionSite.get(:all, params: {client_division_uuid: study.client_division_uuid})
    Euresource::StudyEnvironmentSite.post({client_division_site_uuid: cd_sites.first.uuid,
      study_environment_uuid: study_env.uuid}, {method: 'create'})
  end
end
