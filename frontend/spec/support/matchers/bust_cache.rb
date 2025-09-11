RSpec::Matchers.define :bust_cache do |*action|
  match do |proc|
    params = action.extract_options!
    action = action.first

    # assert normal 200, to get initial etag
    get action, params, {}
    etag = response.headers['ETag']
    assert etag.present?
    assert_equal 200, response.status

    # before busting cache, make sure 304
    request.headers['If-None-Match'] = etag
    get action, params
    assert_equal 304, response.status
    assert_equal '', response.body

    # bust cache and assert 304
    Timecop.freeze(Time.current + 5) { proc.call }
    request.headers['If-None-Match'] = etag
    get action, params
    assert_equal 200, response.status

    # made it through assertions, so return true to pass the matcher
    true
  end
end