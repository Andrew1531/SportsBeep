require 'test_helper'

class NflFantasyEntryTest < ActiveSupport::TestCase
  test 'creation and editing reject before querying records or debiting the wallet' do
    service = Nfl::FantasyEntry.new(user: nil, attributes: {})
    assert_no_difference ['Ticket.count', 'ContestEntryFeeTransaction.count'] do
      error = assert_raises(Nfl::FantasyEntry::EntryError) { service.create! }
      assert_equal SportsbookOnly::MESSAGE, error.message
      error = assert_raises(Nfl::FantasyEntry::EntryError) { service.update!(nil) }
      assert_equal SportsbookOnly::MESSAGE, error.message
    end
  end
end