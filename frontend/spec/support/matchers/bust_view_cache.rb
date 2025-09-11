RSpec::Matchers.define :bust_view_cache do
  match do |proc|
    before_cache_render = render
    before_cache_keys = Rails.cache.instance_variable_get(:@data).keys
    proc.call
    after_cache_render = render
    after_cache_keys = Rails.cache.instance_variable_get(:@data).keys
    Rails.cache.clear
    (before_cache_keys != after_cache_keys) && (before_cache_render != after_cache_render)
  end

  failure_message_for_should do |proc|
    "expected that callable object would bust cache, but it did not"
  end
end