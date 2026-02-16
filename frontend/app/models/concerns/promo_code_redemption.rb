module PromoCodeRedemption
  extend ActiveSupport::Concern

  included do
    attr_accessor :promo_code_text
    validate :promo_code_must_be_valid, if: :promo_code_provided?
    before_save :find_promo_code, if: :promo_code_provided?
  end

  private

    def promo_code_must_be_valid
      unless PromoCode.exists?(code: promo_code_text.strip.upcase)
        errors.add(:promo_code, 'is not valid')
      end
    end

    def find_promo_code
      self.promo_code = PromoCode.find_by(code: promo_code_text.strip.upcase)
    end

    def promo_code_provided?
      promo_code_text.present?
    end

end
