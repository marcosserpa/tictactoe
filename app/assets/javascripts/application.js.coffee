# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require_tree .

# Game Scripts
class GameState
  isX: true
  playerX: 0
  playerO: 0
  moves: 0
  winner: null
  data:
    playerX: 0
    playerO: 0

  gameField: null

  # Sums of columns, rows or diagonals - victory conditions
  winningNumbers: [7, 56, 448, 73, 146, 292, 273, 84]

  constructor: ->
    @gameField = (Math.pow( 2, x ) for x in [0..8]) # Gives each table position a value - [1, 2, 4, 8, 16, 32, 64, 128, 256]
    #  1  |  2  |  4
    #_________________
    #  8  |  16 |  32
    #_________________
    #  64 |  128|  256

    @setPlayersNames()
    @assignRoles()
    @statistics()
    @updateNotifications()

  setPlayersNames: (player_x, player_o) ->
    @data.playerX = player_x
    @data.playerO = player_o

  assignRoles: ->
    roles = ["X", "O"].sort(->
      return 0.5 - Math.random()
    )
    @data.rolepx = roles[0]
    @data.rolepo = roles[1]

  statistics: ->
    @data.pxStats = localStorage[@data.playerX] || wins: 0, loses: 0
    if typeof @data.pxStats is 'string' then @data.pxStats = JSON.parse @data.pxStats
    @data.poStats = localStorage[@data.playerO] || wins: 0, loses: 0
    if typeof @data.poStats is 'string' then @data.poStats = JSON.parse @data.poStats

  getPlayerName: ->
    name = if @data.rolepx == symbol then @data.playerX else @data.playerO
    return name

  updateNotifications: ->
    $(".notifications").empty().show()
    @addNotification "#{@data.playerX} is playing with #{@data.rolepx}"
    @addNotification "#{@data.playerO} is playing with #{@data.rolepo}"
    @addNotification "#{@data.playerX} has #{@data.pxStats.wins} wins and #{@data.pxStats.loses} loses"
    @addNotification "#{@data.playerO} has #{@data.poStats.wins} wins and #{@data.poStats.loses} loses"

  addNotification: (msg) ->
    $(".notifications").append($("<p>", {text: msg}))

  # Define if
  currentSymbol: ->
    if @isX then 'x' else 'o'

  currentPlayer: ->
    if @isX then @playerX else @playerO

  # Check if we have a winner
  checkWinConditions: ->
    for number in @winningNumbers
      if (number & @currentPlayer()) == number
        if @currentSymbol() == 'x'
          localStorage.x++
          @winner = @data.playerX
        else
          localStorage.o++
          @winner = @data.playerO

        @addToScore("#{@currentSymbol().toUpperCase()}")
    if @moves > 8
      @winner = 'Nobody'
      @addToScore("none")

  updateCurrentSymbol: ->
    @isX = !@isX

  updateState: (index) ->
    if @isX
      @playerX += @gameField[index]
    else
      @playerO += @gameField[index]

    @moves++
    @checkWinConditions()
    @updateCurrentSymbol()

  # Update score/leaderboard
  addToScore: (winningParty) ->
    if winningParty isnt 'none'
      if @data.rolepx == winningParty then ++@data.pxStats.wins else ++@data.pxStats.loses
      if @data.rolepo == winningParty then ++@data.poStats.wins else ++@data.poStats.loses
      localStorage[@data.playerX] = JSON.stringify @data.pxStats
      localStorage[@data.playerO] = JSON.stringify @data.poStats

    @updateNotifications()

  # Restart variables to restart game
  reset: ->
    @persist(@winner) unless (@winner == 'none' || @winner == null)

    @isX = true
    @playerX = 0
    @playerO = 0
    @moves = 0
    @winner = null
    $('.notifications').hide()

  showAlert: (msg) ->
    $(".alerts").text(msg).slideDown()

  persist: (winner) ->
    $.ajax
      type: 'POST'
      url: "/save"
      dataType: 'json'
      data: { name: winner }
      success: (data) ->
        console.log("SUCCESS")

# Name input
form = "
  <div class='alerts welcome'></div>
  <div class='notifications'></div>
  <div id='form'>
    <div class='input-group'>
      <div class='input-group-addon'>Player X</div>
      <input class='form-control' id='player_x' type='text' value=''>
    </div>
    <div class='input-group'>
      <div class='input-group-addon'>Player O</div>
      <input class='form-control' id='player_o' type='text' value=''>
    </div>
    <div class='text-center'>
      <input class='btn btn-lg btn-primary' id='submit' onClick='verify_input();' type='button' value='Start'>
    </div>
  </div>
"

gameState = new GameState
{div, h1} = React.DOM

document.addEventListener 'DOMContentLoaded', ->
  React.renderComponent GameField(), document.body
  $('.tic-tac-toe--field').hide()
  $('body').append(form)

GameField = React.createClass
  getInitialState: ->
    gameIsBeingPlayed: false

  render: ->
    div
      className: 'tic-tac-toe--field'
      children: [
        TicTacToeCellsMatrix
          onClick: @onCellClick
          gameIsBeingPlayed: @state.gameIsBeingPlayed
        EndGamePopOver
          onNewGame: @onNewGame
          gameIsBeingPlayed: @state.gameIsBeingPlayed
      ]

  onNewGame: ->
    gameState.reset()
    @setState gameIsBeingPlayed: true

  onCellClick: ->
    if gameState.winner
      @setState gameIsBeingPlayed: false

TicTacToeCell = React.createClass
  getInitialState: ->
    symbol: null

  componentWillReceiveProps: ->
      @setState symbol: null if !@props.gameIsBeingPlayed

  render: ->
    div
      className: @classes()
      onMouseUp: @clickHandler

  classes: ->
    [
      'tic-tac-toe-cell'
      "#{@state.symbol}Symbol" if @state.symbol
    ].join ' '

  # Treats the click in the cell assigning it to those who clicked
  clickHandler: ->
    if !@state.symbol
      @setState symbol: gameState.currentSymbol()
      gameState.updateState(@props.index)
      @props.onClick()

TicTacToeCellsMatrix = React.createClass
  render: ->
    div
      className: 'tic-tac-toe--cells-matrix'
      children: for i in [0..8]
        TicTacToeCell
          index: i
          gameIsBeingPlayed: @props.gameIsBeingPlayed
          onClick: @props.onClick

EndGamePopOver = React.createClass
  render: ->
    div
      className: @classes()
      children: [
        NewGameButton
          onClick: @props.onNewGame
        TitleLabel
          winner: gameState.winner
      ]

  classes: -> [
      'tic-tac-toe--end-game-popover'
      "hidden" if @props.gameIsBeingPlayed
    ].join ' '

TitleLabel = React.createClass
  render: ->
    h1
      className: 'tic-tac-toe--title-label'
      children: "#{@props.winner} won" if @props.winner

NewGameButton = React.createClass
  render: ->
    div
      className: 'tic-tac-toe--new-game-button'
      children: 'New game'
      onMouseUp: @props.onClick


root = exports ? this

root.verify_input = () ->
  $inputs = $("input[type='text']")

  namesNotEntered = $inputs.filter(->
    return @value.trim() isnt ""
  ).length isnt 2

  namesIndentical = $inputs[0].value is $inputs[1].value

  if namesNotEntered
    alert("Player names cannot be empty")
  else if namesIndentical
    alert("Player names cannot be identical")
  else
    gameState.setPlayersNames($('#player_x').val(), $('#player_o').val())
    $('#form').hide()
    $('.tic-tac-toe--field').show()
