class Project < ApplicationRecord
  MAX_ADDITIONAL_PHOTOS = 4

  validates :name, presence: true

  has_many_attached :photos
  has_one_attached :project_photo

  validates :photos, image_attachment: true
  validates :project_photo, image_attachment: true

  validate :photos_count_within_limit

  has_many :tools

  private

  def photos_count_within_limit
    return if photos.attachments.size <= MAX_ADDITIONAL_PHOTOS

    errors.add(
      :photos,
      " : impossible d'ajouter des images supplémentaires. " \
      "La galerie est limitée à #{MAX_ADDITIONAL_PHOTOS} images par projet."
    )
  end
end