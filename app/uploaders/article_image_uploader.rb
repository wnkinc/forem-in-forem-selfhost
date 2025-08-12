require "open-uri"
class ArticleImageUploader < BaseUploader
  def store_dir
    "uploads/articles/"
  end

  def filename
    return unless original_filename.present?

    ext = (file&.extension.presence || File.extname(original_filename).delete(".") || "png")
    base =
      if model && model.respond_to?(:id) && model.id
        "article-#{model.id}-social"
      else
        "social-image"
      end

    "#{base}.#{ext}"
  end

  def upload_from_url(url)
    # Open the URL and create a temporary file
    file = URI.open(url) # rubocop:disable Security/Open
    temp_file = Tempfile.new(["upload", File.extname(file.base_uri.path)])
    temp_file.binmode
    temp_file.write(file.read)
    temp_file.rewind

    # Upload the tempfile using CarrierWave
    store!(temp_file)

    # Important: Ensure you return the URL of the uploaded file
    stored_file_url = self.url # This should return the actual URL where the file is stored

    # Cleanup
    temp_file.close
    temp_file.unlink

    stored_file_url
  rescue StandardError => e
    Rails.logger.error "Failed to handle file upload: #{e.message}"
    nil
  end
end
