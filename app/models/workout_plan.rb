class WorkoutPlan < ApplicationRecord
  belongs_to :user
  has_many :plan_exercises, dependent: :destroy
  has_many :messages, dependent: :nullify

  validates :title, presence: true
  validates :focus_area, inclusion: { in: %w[upper_body lower_body full_body cardio strength flexibility] }, allow_blank: true
  validates :slug, presence: true, uniqueness: { scope: :user_id }, allow_blank: false

  before_validation :generate_slug

  scope :by_focus_area, ->(area) { where(focus_area: area) }
  scope :recent, -> { order(created_at: :desc) }

  def to_param
    slug
  end

  def chat_history
    meta['chat_history'] || []
  end

  def add_to_chat_history(role, content)
    history = chat_history
    history << { role: role, content: content, timestamp: Time.current.iso8601 }
    update!(meta: meta.merge('chat_history' => history))
  end

  private

  def ensure_slug_exists
    if slug.blank?
      generate_slug
      save! if changed?
    end
  end

  def generate_slug
    return if slug.present?

    base_text = meta&.dig('request_text') || title

    base_slug = base_text.to_s.downcase
                        .gsub(/[^a-z0-9\s-]/, '')
                        .gsub(/\s+/, '-')
                        .gsub(/-+/, '-')
                        .strip
                        .slice(0, 50)

    counter = 1
    test_slug = base_slug
    
    while self.class.where(user: user).where(slug: test_slug).where.not(id: id).exists?
      test_slug = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = test_slug
  end
end
