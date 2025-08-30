class User < ApplicationRecord
  has_secure_password
  has_many :orders, dependent: :nullify
  has_many :reservations, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  # Roles: client, angajat (employee), manager, admin
  def role
    (self.tip.presence || "client").downcase
  end

  def client?
    role == "client"
  end

  def employee?
    role == "angajat"
  end

  def manager?
    role == "manager"
  end

  def admin?
    role == "admin"
  end
end
