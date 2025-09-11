module StatReference
  extend ActiveSupport::Concern

  def stat
    StatData.find(super)
  end

  def stat=(statdata)
    case statdata
    when StatData
      super statdata.id
    else
      super statdata
    end
  end

end