class ContestPolicy < Struct.new(:user, :contest)

  def show?
    contest.users.include? user
  end

end
