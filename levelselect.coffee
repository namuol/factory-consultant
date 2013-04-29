define [
  'fragl'
  'util'
  'modules/ui'
  'wadget'
  'puzzles'
], (fr, util, ui, Wadget, puzzles) ->
  class WadgetButton extends Wadget
    init: ->
      super arguments...

      if @disabled
        sheet = new fr.TextureGrid @app.gfx.gfx, 9, 9
        @anim = sheet.anim 32, 50, false
        @scaleX = 1
        @scaleY = 1
        @_drawables = [@]
      else
        @_drawables = @pieces
    getDrawables: -> @_drawables
    onclick: ->
      @app.loadLevel @num

  class LevelSelectScreen extends fr.Actor
    init: ->
      @buttons = []
      i=0
      for lvl in puzzles
        button = new WadgetButton
          disabled: !@app.isLevelUnlocked(i)
          gpos:
            x: i*4 + 1
            y: 4
          num: i
        
        @app.addActor button

        j=0
        for color in lvl.target
          button.pieces[j].color = color
          ++j
        @buttons.push button
        ++i
    update: ->
      super arguments...
      if @dead
        for button in @buttons
          button.dead = true

  return LevelSelectScreen