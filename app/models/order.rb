class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  STATUSES = %w[pending confirmed completed cancelled].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :address, presence: true

  def total_amount
    order_items.sum('quantity * unit_price')
  end
end
