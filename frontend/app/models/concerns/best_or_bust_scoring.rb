module BestOrBustScoring

  def score
    includes(:question).all.to_a.sum(&:score)
  end

end