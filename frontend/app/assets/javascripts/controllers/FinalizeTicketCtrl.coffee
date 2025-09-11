angular.module('sportsbeep.controllers').controller 'FinalizeTicketCtrl', ($window, $scope, $timeout, $interval, $stateParams, BestAndBustAnswerService, CurrentTicket, TimerStateDecoder, PoolService, BestAndBustQuestionService, TicketService, TimerStateService, Ticket) ->
  $scope.state = 'showPools'
  $scope.disableButton = false

  $scope.$watch (-> CurrentTicket.game), (game) ->
    return unless game?
    $scope.game = game
    $scope.pools = PoolService.all(game)
    $scope.pools.$promise.then ->
      $scope.pool = $scope.pools[0]

  $scope.cancelOverlay = ->
    $('.container').removeClass('blurred')
    $('.overlay').hide()
    $scope.state = 'showPools'
    $scope.pool = $scope.pools[0]

  $scope.beginQuestionAnswering = ->
    $scope.state = 'bestAndBust'
    $scope.currentQuestionIndex = -1
    $scope.nextQuestion()

  $scope.selectPool = ->
    CurrentTicket.pool = $scope.pool
    $scope.state = 'paymentConfirmation'

  $scope.confirmPayment = ->
    $scope.createTicket()

  $scope.createTicket = ->
    $scope.disableButton = true
    console.log $scope.disableButton
    $spinner = $('.confirm-payment .fa-spinner')
    $spinner.show()
    TicketService.createTicket(CurrentTicket.serialize()).success (data) =>
      $scope.ticket = new Ticket(data)

      $scope.bestAndBustQuestions = BestAndBustQuestionService.all($scope.ticket)
      $scope.bestAndBustQuestions.$promise.then (data) =>
        $spinner.hide()
        $scope.state = 'quizTime'

      $scope.timerStates = TimerStateService.all($scope.ticket).$promise.then (data) ->
        $scope.timerStateMap = TimerStateDecoder.generateTimerStateMap($scope.ticket.id, data)

    .error (data) ->
      $scope.error = data.error
      $spinner.hide()

  $scope.stringifyPool = (pool) ->
    "Pay $#{pool.entry_fee} for a $#{pool.prize_pool} pool"

  $scope.selectHomeTeam = ->
    $scope.selectTeam($scope.game.home_team)

  $scope.selectAwayTeam = ->
    $scope.selectTeam($scope.game.away_team)

  $scope.selectTeam = (team) ->
    $scope.currentQuestion.answer = team
    $scope.currentQuestion.time = $scope.bestAndBustTime
    $scope.nextQuestion()

  $scope.nextQuestion = ->
    $scope.currentQuestionIndex++
    $scope.currentQuestion = $scope.bestAndBustQuestions[$scope.currentQuestionIndex]

    if $scope.currentQuestion?
      # For some reason the binding in the view was not being picked up by the digest, so we have to
      # manually trigger it here
      $timeout -> $scope.$apply()
      $scope.startTimer()
    else
      $scope.state = 'sendingAnswers'
      payload = []

      $scope.timerStateMap.then (map) ->
        for question in $scope.bestAndBustQuestions
          payload.push
            question_id: question.id
            answer_id: question.answer.id
            time: map[question.time]

        BestAndBustAnswerService.submit($scope.ticket.id, { answers: payload }).finally (data) ->
          $scope.state = 'ticketFinalized'

  $scope.startTimer = ->
    $scope.bestAndBustTime = 14.0
    $interval.cancel($scope.timer)
    $scope.timer = $interval ->
      time = Number($scope.bestAndBustTime - 0.1).toFixed(1)
      time = 0.0 if time < 0
      $scope.bestAndBustTime = time
    , 100

