module UploadValidations
  def self.included(base)
    base.validates :study_uuid, presence: true
    base.validates :candidates_file, presence: true
    base.validate :candidates_file_contents, on: :create
    base.validates :candidates_file_content_type, inclusion: %w[
      text/csv
      text/comma-separated-values
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/csv
      application/excel
      application/vnd.ms-excel
      application/vnd.msexcel
      application/octet-stream
    ]
  end
end
