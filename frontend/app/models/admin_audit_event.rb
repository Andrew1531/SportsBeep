class AdminAuditEvent < ActiveRecord::Base
  ACTIONS = %w[personal_info_corrected personal_info_removed password_reset].freeze

  belongs_to :actor, class_name: 'Administrator'
  belongs_to :user

  serialize :changed_fields, Array

  validates :actor, :user, :reason, presence: true
  validates :action, inclusion: { in: ACTIONS }
  validate :changed_fields_are_names_only

  private

  def changed_fields_are_names_only
    unless changed_fields.is_a?(Array) &&
           changed_fields.all? { |field| field.to_s.match?(/\A[a-z0-9_.]+\z/) }
      errors.add(:changed_fields, 'must contain field names only')
    end
  end
end