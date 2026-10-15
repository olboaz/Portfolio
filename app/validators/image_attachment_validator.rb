class ImageAttachmentValidator < ActiveModel::EachValidator
  ALLOWED_TYPES = %w[
    image/jpeg
    image/png
    image/webp
  ].freeze

  MAX_SIZE = 5.megabytes

  def validate_each(record, attribute, value)
    return unless record.attachment_changes.key?(attribute.to_s)
    
    blobs =
      if value.respond_to?(:blobs)
        value.blobs
      elsif value.respond_to?(:blob)
        [value.blob].compact
      else
        []
      end

    blobs.each do |blob|
      unless ALLOWED_TYPES.include?(blob.content_type)
        record.errors.add(attribute, "doit être une image JPEG, PNG ou WebP")
      end

      if blob.byte_size > MAX_SIZE
        record.errors.add(attribute, "ne doit pas dépasser 5 Mo")
      end
    end
  end
end