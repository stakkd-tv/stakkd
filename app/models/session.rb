class Session < ApplicationRecord
  self.strict_loading_by_default = true

  belongs_to :user
end
