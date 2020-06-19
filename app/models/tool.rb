class Tool < ApplicationRecord
  validates :name, presence: true
  has_one_attached :tool_photo
  has_many :projects
end
