describe Api::RegistrationsController, version: 2 do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:api_user]
  end

  describe "POST create" do
    it "creates a new user" do
      post :create, { api_user: { email: 'test@email.com', password: 'password', username: 'testerson' } }
      response.status.should == 201
      User.should exist(email: 'test@email.com')
      User.find_by(email: 'test@email.com').promo_code.should be_nil
    end

    describe 'Promo codes' do
      before do
        Fabricate :promo_code, code: 'TEST123'
      end

      it 'sends a promo code' do
        post :create, { api_user: { email: 'test@email.com', password: 'password', username: 'testerson', promo_code: 'TEST123' } }
        User.find_by(email: 'test@email.com').promo_code.code.should == 'TEST123'
      end

      it 'validates the promo code is present even if not required' do
        post :create, { api_user: { email: 'test@email.com', password: 'password', username: 'testerson', promo_code: 'NOPE' } }
        response.status.should == 422
        controller.resource.should have_error_message /Promo code is not valid/
      end

      it 'fails to create without a promo code if the require promo code setting is true' do
        Setting.first.update require_promo_code_on_signup: true
        post :create, { api_user: { email: 'test@email.com', password: 'password', username: 'testerson' } }
        response.status.should == 422
        controller.resource.should have_error_message /Promo code must be provided/
      end
    end

    context "incorrect post parameters" do
      after { response.status.should == 422 }

      it "returns an error when the password is too short" do
        post :create, { api_user: { email: 'test@email.com', password: 'short', username: 'testerson' } }
        controller.resource.should have_error_message /Password is too short/
      end

      it "returns an error when the e-mail is a duplicate" do
        Fabricate(:user, email: 'test2@test.com')
        post :create, { api_user: { email: "test2@test.com", password: "password", username: 'testerson' } }
        controller.resource.should have_error_message /Email has already been taken/
      end
    end
  end

  describe 'PUT update' do
    include_context 'authenticated', :user

    it "updates the users attributes" do
      put :update, api_user: { first_name: 'Testerson' }
      response.status.should == 200
      user.reload.first_name.should == 'Testerson'
      json[:avatar_url].should =~ %r[/uploads/user/avatar/1/avatar-(.*).png]
    end

    it 'uploads an avatar' do
      avatar = Rack::Test::UploadedFile.new File.open(Rails.root.join('spec', 'support', 'test-avatar.png'))
      put :update, api_user: { avatar: avatar }
      response.status.should == 200
      user.reload.avatar.should be_present
    end

    it 'deletes an avatar' do
      avatar = Rack::Test::UploadedFile.new File.open(Rails.root.join('spec', 'support', 'test-avatar.png'))
      put :update, api_user: { avatar: avatar }
      response.status.should == 200
      json[:avatar_url].should be_present
      put :update, api_user: { remove_avatar: true }
      response.status.should == 200
      json[:avatar_url].should be_nil
    end

    context 'saving device token' do
      it 'updates the push device token and platform' do
        put :update, { api_user: { device_token: '123', platform: 'android' } }
        response.status.should == 200
        user.reload
        user.device_token.should == '123'
        user.platform.should == 'android'
      end
    end

    context "incorrect post parameters" do
      it "returns an error when the users email is a duplicate" do
        Fabricate(:user, email: 'test123@test.com', password: 'password')
        put :update, api_user: { email: "test123@test.com" }
        response.status.should == 422
        controller.resource.should have_error_message /Email has already been taken/
      end
    end

  end
end