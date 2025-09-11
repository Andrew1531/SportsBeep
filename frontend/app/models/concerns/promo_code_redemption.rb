module PromoCodeRedemption
  extend ActiveSupport::Concern

  included do
    attr_accessor :promo_code_text
    validate :promo_code_must_be_provided, on: :create, if: :requires_promo_code_to_signup?
    validate :promo_code_must_be_valid, if: :promo_code_provided?
    before_save :find_promo_code, if: :promo_code_provided?
  end

  private

    def promo_code_must_be_provided
      if promo_code_text.blank?
        errors[:promo_code] << 'must be provided'
      end
    end

    def promo_code_must_be_valid
      unless PromoCode.exists?(code: promo_code_text)
        errors[:promo_code] << 'is not valid'
      end
    end

    def find_promo_code
      self.promo_code = PromoCode.find_by(code: promo_code_text)
    end

    def requires_promo_code_to_signup?
      Setting.first.require_promo_code_on_signup?
    end

    def promo_code_provided?
      promo_code_text.present?
    end

end