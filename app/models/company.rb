class Company < ApplicationRecord
  has_many_attached :logos

    def logo = logos.first || "2:3.png"
end
