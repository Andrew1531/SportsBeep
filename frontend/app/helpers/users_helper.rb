module UsersHelper

  def avatar_for(user)
    user.avatar_url || 'silhouette.png'
  end

end
