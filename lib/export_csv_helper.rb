module ExportCsvHelper

  # Generates a CSV file of users with persistence errors in the first column
  def export_failed_users_csv(list)
    errors = { human_readable_errors: I18n.t('study.users_uploads.review.list.review_user_list.has_error') }
    generate_export_csv(list, errors.merge(user_csv_attributes))
  end

  # Generates various CSV files with different lists of users
  def export_users_csv(list)
    generate_export_csv(list, user_csv_attributes)
  end

  def export_failed_sites_csv(list)
    errors = { human_readable_errors: I18n.t('study.sites_uploads.review.list.review_site_list.has_error') }
    generate_export_csv(list, errors.merge(site_csv_attributes))
  end

  # Generates various CSV files with different lists of sites
  def export_sites_csv(list)
    generate_export_csv(list, site_csv_attributes)
  end

  def export_csv_file(data, filename)
    respond_to do |format|
      format.csv { send_data data, filename: filename, type: :csv, disposition: 'attachment' }
    end
  end

private
  
  # This method generates a CSV file from an array of objects and a hash of attributes to store.
  # The hash must contain keys representing object attributes and values representing the
  # corresponding column headers.
  def generate_export_csv objects, attributes
    CSV.generate do |csv|
      csv << attributes.values
      objects.each do |item|
        csv << attributes.keys.map { |attr| item.send(attr) }
      end
    end
  end

  def user_csv_attributes
    required_fields = I18n.t('study.shared.uploads.file_upload_body.users_required_fields')
    optional_fields = I18n.t('study.shared.uploads.file_upload_body.users_optional_fields')

    {
      email: required_fields[:email],
      first_name: required_fields[:first_name],
      last_name: required_fields[:last_name],
      role: required_fields[:role],
      environment_name: required_fields[:environment],
      telephone: optional_fields[:phone_number],
      site: optional_fields[:site]
    }
  end

  def site_csv_attributes
    required_fields = I18n.t('study.shared.uploads.file_upload_body.sites_required_fields')

    {
      medical_facility_name: required_fields[:medical_facility_name],
      client_division_site_number: required_fields[:client_division_site_number],
      study_environment_site_number: required_fields[:study_environment_site_number],
      pi_email_address: required_fields[:pi_email_address],
      pi_first_name: required_fields[:pi_first_name],
      pi_last_name: required_fields[:pi_last_name],
      pi_role: required_fields[:pi_role],
      environment: required_fields[:environment],
      site_name: required_fields[:site_name],
      address_1: required_fields[:address_1],
      city: required_fields[:city],
      state: required_fields[:state],
      country: required_fields[:country],
      postal_code: required_fields[:postal_code]
    }
  end
end
