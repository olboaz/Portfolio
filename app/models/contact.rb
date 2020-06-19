class Contact < ApplicationRecord
  validates :name, presence: { message: 'ne peut pas être vide' }
  validates :email,
    presence: true, presence: { message: 'ne peut pas être vide' },
    format: {
      with: /\S+@\S+\.\S+/i,
      message: "format de l'email non valide"
    }
  validates :message, presence: { message: 'ne peut pas être vide' }
end
