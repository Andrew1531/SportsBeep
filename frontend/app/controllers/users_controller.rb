class UsersController < ApplicationController
  before_action :authenticate_user!, only: :update_profile_photo

  def show
    @user = User.find params[:id]
  end

  def update_profile_photo
    photo = params[:profile_photo]

    if photo.blank?
      redirect_to user_dashboard_path, alert: 'Choose a photo to upload.'
      return
    end

    allowed_types = %w[image/jpeg image/png image/webp]
    detected_type = Marcel::MimeType.for(photo.tempfile, name: photo.original_filename)
    unless allowed_types.include?(detected_type)
      redirect_to user_dashboard_path, alert: 'Please upload a JPG, PNG, or WebP image.'
      return
    end

    if photo.size > 5.megabytes
      redirect_to user_dashboard_path, alert: 'Profile photos must be smaller than 5 MB.'
      return
    end

    current_user.profile_photo.attach(photo)
    redirect_to user_dashboard_path, notice: 'Profile photo updated.'
  rescue ActiveStorage::Error => e
    Rails.logger.error("[profile_photo] #{e.class}: #{e.message}")
    redirect_to user_dashboard_path, alert: 'We could not save that photo. Please try another image.'
  end

end
