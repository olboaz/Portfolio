class Contact < ApplicationRecord
  validates :name, presence: { message: 'ne peut pas être vide' }

  validates :email,
    presence: { message: 'ne peut pas être vide' },
    format: {
      with: /\S+@\S+\.\S+/i,
      message: "format de l'email non valide"
    }

  validates :message, presence: { message: 'ne peut pas être vide' }

  validates :name,
    length: { maximum: 100, message: "ne peut pas dépasser 100 caractères" }

  validates :email,
    length: { maximum: 254, message: "ne peut pas dépasser 254 caractères" }

  validates :message,
    length: { maximum: 2000, message: "ne peut pas dépasser 2000 caractères" }

end