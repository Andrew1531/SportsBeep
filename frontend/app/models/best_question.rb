class BestQuestion < Question

  def kind
    'Best'
  end

  def comparison_operator
    (comparison == 'more') ? :> : :<
  end

end