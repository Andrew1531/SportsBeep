class BustQuestion < Question

  def kind
    'Bust'
  end

  def comparison_operator
    (comparison == 'more') ? :< : :>
  end

end