Fabricator(:promo_code) do
  code { SecureRandom.hex }
  note ''
end
