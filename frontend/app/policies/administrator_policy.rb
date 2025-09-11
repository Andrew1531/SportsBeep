class AdministratorPolicy < Struct.new(:user, :administrator)

  def destroy?
    user != administrator
  end

end
