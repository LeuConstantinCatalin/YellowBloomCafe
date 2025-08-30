class DiningTable < ApplicationRecord
  has_many :reservations, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :seats, numericality: { greater_than: 0 }
end

