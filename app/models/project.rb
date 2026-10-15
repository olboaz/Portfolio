class Project < ApplicationRecord
  validates :name, presence: true

  has_many_attached :photos
  has_one_attached :project_photo

  validates :photos, image_attachment: true
  validates :project_photo, image_attachment: true

  has_many :tools
end