class Tool < ApplicationRecord
  validates :name, presence: true

  has_one_attached :tool_photo

  validates :tool_photo, image_attachment: true

  has_many :projects
end