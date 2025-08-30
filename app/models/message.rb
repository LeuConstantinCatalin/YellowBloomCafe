class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { minimum: 3 }
end

