class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :gym_location
end
