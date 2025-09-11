shared_examples_for 'http cached index' do

  it 'returns a 200 with an e-tag the first time' do
    get :index
    response.headers.should include 'ETag'
    response.status.should == 200
  end

  it 'returns a 304 blank response the second time if the resource hasnt changed' do
    get :index
    response.status.should == 200
    @request.headers['If-None-Match'] = response.headers['ETag']
    get :index
    response.status.should == 304
    response.body.should == ''
  end

  it 'returns a 200 the second time if a resource has changed' do
    get :index
    @request.headers['If-None-Match'] = response.headers['ETag']
    Timecop.freeze(Time.current + 5) { bust_cache! }
    get :index
    response.status.should == 200
  end

end