# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :user

  enum status: {
    pending: 'pending',
    success: 'success',
    failed: 'failed'
  }
end
