module Api::AvatarHelper

  def avatar_size
    size = params[:avatar_size]
    possible_sizes = %w(mdpi hdpi xhdpi xxhdpi)
    if possible_sizes.include?(size)
      size
    else
      'xxhdpi'
    end
  end

end