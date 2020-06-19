class Project < ApplicationRecord
  validates :name, presence: true
  has_many_attached :photos
  has_one_attached :project_photo
  has_many :tools
end
