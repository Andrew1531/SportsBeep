json.(answer, :time)
json.score OneDecimalOrWhole.new.format(answer.score)
json.correct answer.correct?

json.question do
  json.partial! 'api/resources/question', question: answer.question
end

json.team do
  json.id answer.answer.id
end