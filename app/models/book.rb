class Book < ApplicationRecord
    enum :status, { available: "available", reserved: "reserved", checked_out: "checked_out" }

    validates :title, presence: true

    validates :reserved_by_email, presence: true, if: :reserved?
    validates :reserved_by_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
