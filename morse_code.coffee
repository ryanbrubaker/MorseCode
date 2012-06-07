
kDotToken = 0
kDashToken = 1
kWordStopToken = 2

class CommunicationLine extends Backbone.Model
   initialize: (options) =>
      @inputQueue = []
      @communicationLine = ['', '', '', '', '', '', '', '', '', '']
      @decoder = options.decoder
      setInterval(@moveDataOneStep, 100)

   addToken: (token) =>
      @inputQueue.push(token)

   moveDataOneStep: =>
      @decoder.processToken(@communicationLine.pop())
      nextToken = @inputQueue.shift()
      @communicationLine.unshift(if undefined == nextToken then '' else nextToken)
      @trigger('hasNewData', @communicationLine)
      
      
class MorseDecoder extends Backbone.Model

   initializeKey: =>
      @key = {}
      @key['' + kDotToken + kDashToken] = 'A'
      @key['' + kDashToken + kDotToken + kDotToken + kDotToken] = 'B'
      @key['' + kDashToken + kDotToken + kDashToken + kDotToken] = 'C'
      @key['' + kDashToken + kDotToken + kDotToken] = 'D'
      @key['' + kDotToken] = 'E'
      @key['' + kDotToken + kDotToken + kDashToken + kDotToken] = 'F'
      @key['' + kDashToken + kDashToken + kDotToken] = 'G'
      @key['' + kDotToken + kDotToken + kDotToken + kDotToken] = 'H'
      @key['' + kDotToken + kDotToken] = 'I'
      @key['' + kDotToken + kDashToken + kDashToken + kDashToken] = 'J'
      @key['' + kDashToken + kDotToken + kDashToken] = 'K'
      @key['' + kDotToken + kDashToken + kDotToken + kDotToken] = 'L'
      @key['' + kDashToken + kDashToken] = 'M'
      @key['' + kDashToken + kDotToken] = 'N'
      @key['' + kDashToken + kDashToken + kDashToken] = 'O'
      @key['' + kDotToken + kDashToken + kDashToken + kDotToken] = 'P'
      @key['' + kDashToken + kDashToken + kDotToken + kDashToken] = 'Q'
      @key['' + kDotToken + kDashToken + kDotToken] ='R'
      @key['' + kDotToken + kDotToken + kDotToken] = 'S'
      @key['' + kDashToken] = 'T'
      @key['' + kDotToken + kDotToken + kDashToken] = 'U'
      @key['' + kDotToken + kDotToken + kDotToken + kDashToken] = 'V'
      @key['' + kDotToken + kDashToken + kDashToken] = 'W'
      @key['' + kDashToken + kDotToken + kDotToken + kDashToken] = 'X'
      @key['' + kDashToken + kDotToken + kDashToken + kDashToken] = 'Y'
      @key['' + kDashToken + kDashToken + kDotToken + kDotToken] = 'Z'
   
   initialize: =>
      @inputTokens = []
      @numEmptyTokensInARow = 0
      @initializeKey()
      
      
   processToken: (token) =>
      if token == ''
         @parseTokens() if ++@numEmptyTokensInARow >= 10
      else if token == kWordStopToken
         @parseTokens() if @inputTokens.length > 0
         @trigger('parsedCharacter', ' ')
      else
         @inputTokens.push(token)
         @numEmptyTokensInARow = 0
   
   parseTokens: =>
      if @inputTokens.length > 0
         token = @key[@inputTokens.join('')]
         @trigger('parsedCharacter', token) if token != undefined
      @numEmptyTokensInARow = 0
      @inputTokens.length = 0
       

class StraightKeyInput extends Backbone.View

   initialize: ->
      @dashTimer = null
      @dashFlag = false
      @wordStopTimer = null
      @wordStopFlag = false

   events:
      'mousedown #straight-key': 'startTimers',
      'mouseup #straight-key': 'sendUserInput'
      
   startTimers: =>
      @dashTimer = setTimeout(@dashTimerExpired, 250)
      @wordStopTimer = setTimeout(@wordStopTimerExpired, 1000)
      
   dashTimerExpired: =>
      @dashFlag = true
      
   wordStopTimerExpired: =>
      @wordStopFlag = true
   
   sendUserInput: =>
      if @wordStopFlag
         @model.addToken(kWordStopToken)
      else if @dashFlag
         @model.addToken(kDashToken)
      else
         @model.addToken(kDotToken)

      clearTimeout(@dashTimer)
      clearTimeout(@wordStopTimer)
      @dashFlag = false
      @wordStopFlag = false


class CommunicationLineView extends Backbone.View
   initialize: ->
      @model.bind('hasNewData', @render)
      
   render: (tokens) =>
      context = document.getElementById("communicationLineCanvas").getContext('2d')
      context.clearRect(0, 0, context.canvas.width, 29)
      tokenNum = 0
      for token in tokens
         do (token) ->
            if kDotToken == token
               context.beginPath()
               context.moveTo((50 * tokenNum) + 15, 15)
               context.arc((50 * tokenNum) + 15, 15, 10, 0, Math.PI*2, false)
               context.closePath()
               context.fill()
               context.stroke()
            else if kDashToken == token
               context.fillRect((50 * tokenNum) + 15, 15, 25, 10)
            else if kWordStopToken == token
               context.fillRect((50 * tokenNum) + 30, 5, 10, 20)
            tokenNum += 1
            

class DecoderView extends Backbone.View
   initialize: ->
      @model.bind('parsedCharacter', @render)
   
   render: (token) =>
      messageBox = $('#messageBox')
      messageBox.val(messageBox.val() + token)

               
drawSignalLine = ->
   context = document.getElementById("communicationLineCanvas").getContext('2d')
   context.clearRect(0, 0, context.canvas.width, context.canvas.height)
   context.moveTo(0, 30)
   context.lineTo(500, 30)
   context.strokeStyle = "#000"
   context.closePath()
   context.stroke()
      
init = ->
   decoder = new MorseDecoder
   communicationLine = new CommunicationLine('decoder': decoder)
   straightKey = new StraightKeyInput('el': $('#straight-key-div'), 'model': communicationLine)
   communicationLineView = new CommunicationLineView('el': $('#communication-line-div'), 'model': communicationLine)
   decoderView = new DecoderView('el': $('messageBoxDiv'), 'model':decoder)
   
   drawSignalLine()

$(document).ready init


