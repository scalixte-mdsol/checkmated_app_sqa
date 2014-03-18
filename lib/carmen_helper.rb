# TODO this was copied from Plinth's codebase

require 'carmen'

# helper methods when using Carmen to validate states/countries
module CarmenHelper
  include Carmen

  def get_iso_state(state, country)
    # if state is blank or country is blank, don't need to process. Carmen will error if nil passed.
    return nil unless state.present? && country.present?
    iso_country = get_iso_country(country)
    # country may be invalid, thus won't have subregions
    return nil if iso_country.nil?
    iso_country.subregions.named(state) || iso_country.subregions.coded(state)
  end

  def get_iso_country(country)
    return nil unless country.present?
    Country.coded(country) || Country.named(country)
  end

  def valid_country?(country)
    get_iso_country(country)
  end

  def state_in_country?(state, country)
    get_iso_state(state, country)
  end

  def get_state_country_codes(state, country)
    iso_country = get_iso_country(country)
    iso_state = get_iso_state(state, country)

    country_code = iso_country ? iso_country.alpha_3_code : country
    state_code = iso_state ? iso_state.code : state

    return state_code, country_code
  end
  
  # Returns true if the given country has any states and false otherwise.
  # Returns false if the given country isn't valid.
  def country_has_states?(country)
    iso_country = get_iso_country(country)
    iso_country.present? && iso_country.subregions?
  end

end
