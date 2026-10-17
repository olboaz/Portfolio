class Project < ApplicationRecord
  MAX_ADDITIONAL_PHOTOS = 4

  validates :name, presence: true
  validate :url_must_be_valid_http_url

  has_many_attached :photos
  has_one_attached :project_photo

  validates :photos, image_attachment: true
  validates :project_photo, image_attachment: true

  validate :photos_count_within_limit

  has_many :tools

  def valid_external_url?
    url.present? && url_must_be_valid_http_url?
  end

  private

  def photos_count_within_limit
    return if photos.attachments.size <= MAX_ADDITIONAL_PHOTOS

    errors.add(
      :photos,
      " : impossible d'ajouter des images supplémentaires. " \
      "La galerie est limitée à #{MAX_ADDITIONAL_PHOTOS} images par projet."
    )
  end

  def url_must_be_valid_http_url
    return if url.blank?

    unless url_must_be_valid_http_url?
      errors.add(:url, "doit être une URL HTTP ou HTTPS valide")
    end
  end

  def url_must_be_valid_http_url?
    uri = URI.parse(url)

    return false unless uri.is_a?(URI::HTTP)
    return false unless %w[http https].include?(uri.scheme)
    return false if uri.host.blank?
    return false if uri.userinfo
    return false if url.match?(/[\\\s]/)
    return false unless uri.port.between?(1, 65_535)

    host = uri.host.downcase.delete_suffix(".")

    return false if host.empty?
    return false if host.length > 253

    host.split(".", -1).all? do |label|
      label.length.between?(1, 63) &&
        label.match?(/\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/)
    end
  rescue URI::InvalidURIError
    false
  end
end