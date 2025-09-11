describe NotifyWinners, sport: 'Mlb' do

  let(:user) { Fabricate(:user, device_token: '123abc', platform: 'android') }

  let(:tickets) do
    [
      Fabricate(:ticket, placing: 1, user: user),
      Fabricate(:ticket, placing: 2, user: user),
      Fabricate(:ticket, placing: 3, user: user)
    ]
  end

  it 'sends a push to each ticket' do
    subject.perform(tickets)

    WebMock.should have_requested(:post, %r[gcm/send]).with(body: \
      "{\"registration_ids\":[\"123abc\"],\"data\":{\"type\":\"placement\",\"contest\":1,\"game\":1,\"ticket\":1,\"placing\":1,\"sport\":\"mlb\"},\"collapse_key\":null,\"time_to_live\":null,\"delay_while_idle\":null}")

    WebMock.should have_requested(:post, %r[gcm/send]).with(body: \
      "{\"registration_ids\":[\"123abc\"],\"data\":{\"type\":\"placement\",\"contest\":2,\"game\":2,\"ticket\":2,\"placing\":2,\"sport\":\"mlb\"},\"collapse_key\":null,\"time_to_live\":null,\"delay_while_idle\":null}")

    WebMock.should have_requested(:post, %r[gcm/send]).with(body: \
      "{\"registration_ids\":[\"123abc\"],\"data\":{\"type\":\"placement\",\"contest\":3,\"game\":3,\"ticket\":3,\"placing\":3,\"sport\":\"mlb\"},\"collapse_key\":null,\"time_to_live\":null,\"delay_while_idle\":null}")
  end

end