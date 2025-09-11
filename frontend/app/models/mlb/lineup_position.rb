class Mlb::LineupPosition < ::LineupPosition

  def position=(pos)
    pos = {
      1  => 'SP',
      2  => 'C',
      3  => '1B',
      4  => '2B',
      5  => '3B',
      6  => 'SS',
      7  => 'LF',
      8  => 'CF',
      9  => 'RF',
      10 => 'DH',
      11 => 'PH',
      12 => 'PR'
    }[pos.to_i]
    super(pos)
  end

end
