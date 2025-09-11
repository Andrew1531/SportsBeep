json.cache! question do
  json.(question, :id, :text)
  json.type question.kind.downcase
end
