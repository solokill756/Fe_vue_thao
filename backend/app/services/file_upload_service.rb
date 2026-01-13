class FileUploadService
  ALLOWED_TYPES = {
    'application/pdf' => 'pdf',
    'application/msword' => 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'text/plain' => 'txt'
  }.freeze

  MAX_FILE_SIZE = 100.megabytes

  def self.upload_submission_file(file)
    new.upload(file)
  end

  def upload(file)
    return error_result('File does not exist') if file.blank?
    return error_result("File too large (maximum #{MAX_FILE_SIZE / 1.megabyte}MB)") if file.size > MAX_FILE_SIZE

    unless ALLOWED_TYPES.key?(file.content_type)
      return error_result('File type not supported. Supported types: PDF, DOCX, TXT, JPG, PNG')
    end

    {
      success: true,
      file_name: file.original_filename,
      file: file
    }
  rescue StandardError => e
    error_result("Error uploading file: #{e.message}")
  end

  private

  def error_result(message)
    { success: false, error: message }
  end
end
