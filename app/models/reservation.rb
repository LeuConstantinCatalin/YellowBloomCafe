class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :dining_table, optional: true

  STATUSES = %w[requested assigned completed cancelled].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :starts_at, presence: true
  validates :seats, numericality: { greater_than: 0 }
  validates :duration_minutes, numericality: { greater_than: 0 }

  scope :upcoming, -> { where("starts_at >= ?", Time.current) }

  def ends_at
    starts_at + duration_minutes.minutes
  end


  def overlaps_for_table?(table)
    return false unless table
    s = starts_at
    e = ends_at
    Reservation.where(dining_table: table, status: 'assigned')
               .where.not(id: id)
               .any? { |r| s < (r.starts_at + r.duration_minutes.minutes) && e > r.starts_at }
  end
end
