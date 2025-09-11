json.contests @contests do |contest|
  ticket = @tickets.find { |t| t.contest == contest }
  json.cache! [contest, ticket, current_user] do
    json.partial! 'api/resources/contest', contest: contest
    json.ticket do
      json.partial! 'api/resources/ticket', ticket: ticket
    end
  end
end