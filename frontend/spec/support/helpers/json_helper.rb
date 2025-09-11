module JSONHelper

  def json
    JSON[response.body].with_indifferent_access
  end

end