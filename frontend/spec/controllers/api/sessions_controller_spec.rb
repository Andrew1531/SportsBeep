describe Api::SessionsController, version: 2 do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:api_user]
  end

  describe 'POST create' do
    it 'signs in the user and returns the authentication token' do
      Fabricate(:user, email: 'test@test.com', password: 'password')
      post :create, { api_user: { email: "test@test.com", password: "password" } }
      response.status.should == 201
    end

    it 'shows the users avatar URL' do
      user = Fabricate(:user, email: 'test@test.com', password: 'password')
      user.update avatar: File.open(Rails.root.join('spec', 'support', 'test-avatar.png'))
      post :create, { api_user: { email: "test@test.com", password: "password" } }
      json[:avatar_url].should =~ %r[/uploads/user/avatar/#{user.id}/avatar-(.*).png]
    end

    context 'incorrect password' do
      it 'returns an error message when the password is incorrect' do
        Fabricate :user, email: 'test@test.com', password: 'password'
        post :create, { api_user: { email: 'test@test.com', password: 'nope' } }
        response.status.should == 401
      end
    end

    context 'user not found' do
      it "returns an error message when the user cant be found" do
        post :create, { api_user: { email: "unknown@email.com", password: "password" } }
        response.status.should == 401
      end
    end
  end

  describe 'DELETE destroy' do
    let(:user) { Fabricate :user }

    before do
      post :create, { api_user: { email: user.email, password: user.password } }
      response.status.should == 201
    end

    it 'clears the device token and platform' do
      delete :destroy, authentication_token: user.authentication_token
      user.reload.device_token.should be_nil
      user.reload.platform.should be_nil
    end

  end
end
