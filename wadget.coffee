define [
  'fragl'
  'util'
  'modules/ui'
], (fr, util, ui)->
  WHITE = 0
  BLACK = 1
  RED = 2

  UP = 0
  DOWN = 1
  LEFT = 2
  RIGHT = 3

  GRID_W = 3

  class WadgetPiece extends fr.Actor
    width: 3
    height: 3
    color: WHITE
    drawOrder: 2
    init: ->
      super arguments...
    update: ->
      super arguments...
      @anim = @app.colors[@color]

      if @exploding
        @pos.x += (@dest.x - @pos.x) * 0.2
        @pos.y += (@dest.y - @pos.y) * 0.2
        @rot += (@dest.r - @rot) * 0.2
        return

      @pos.x = @parent.pos.x + @offset.x
      @pos.y = @parent.pos.y + @offset.y

      if @app.machines.painters?
        for p in @app.machines.painters
          if (@color in p.paintsOver) and not p.dragging and @touches(p)
            @color = p.color
            @anim = @app.colors[@color]
            @app.sfx.bloop.play(0.5)
      #@visible = @color is not WHITE

  class Wadget extends fr.Actor
    @WHITE: WHITE
    @BLACK: BLACK
    @RED: RED
    @UP: UP
    @DOWN: DOWN
    @LEFT: LEFT
    @RIGHT: RIGHT
    width: 9
    height: 9
    delay: 0
    init: ->
      @sheet = new fr.TextureGrid @app.gfx.gfx, 3, 3
      @anim = @sheet.anim 0, 50, false
      @scaleX = @scaleY = 3
      #@gpos ?=
      #  x:0
      #  y:0
      @pos.x = @gpos.x * GRID_W
      @pos.y = @gpos.y * GRID_W
      @pieces = []
      i=0
      while i < 9
        piece = new WadgetPiece
          parent: @
          offset:
            x: (i%3) * 3
            y: (Math.floor(i/3)) * 3
          frame: 0
        piece.app = @app
        piece.init()
        @pieces.push piece
        ++i
      @stepNum = 0
      @behaviors.push ui.MouseInteractive
      super
    onmouseover: ->
      for p in @pieces
        p.alpha = 0.5
    onmouseout: ->
      for p in @pieces
        p.alpha = 1
    getDrawables: -> @pieces
    nextPos: ->
      next = 
        x: @gpos.x
        y: @gpos.y
      switch @direction
        when UP
          next.y -= 1
        when DOWN
          next.y += 1
        when LEFT
          next.x -= 1
        when RIGHT
          next.x += 1
      return next
    step: ->
      ++@stepNum

      @pos.x = @gpos.x * GRID_W
      @pos.y = @gpos.y * GRID_W

      if @app.machines.arrows?
        for m in @app.machines.arrows
          continue if !m.toggled
          if m.direction? and @pieces[0].touches m.collisionObj
            @direction = m.direction
            break
      
      if @delay > 0
        --@delay
      else if @app.machines.delays?
        for m in @app.machines.delays
          if @pieces[0].touches m.collisionObj
            @delay = 3

      for c in @app.machines.wadgetCatchers
        if @pieces[0].touches c.collisionObj
          @app.removeWadget @
          @dead = true
          c.catchWadget @

      if @delay==0
        @gpos = @nextPos()

      if @gpos.x < Wadget.MIN_GX or @gpos.x > Wadget.MAX_GX or @gpos.y < Wadget.MIN_GY or @gpos.y > Wadget.MAX_GY
        @kill()

    update: (dt) ->
      super arguments...

      if @exploding
        if @ttl < 0
          @dead = true
        for p in @pieces
          p.update arguments...
          p.alpha = @ttl / @ttl_start
        @ttl -= dt
        return

      next = @gpos
      @pos.x += (next.x * GRID_W - @pos.x) * 0.6
      @pos.y += (next.y * GRID_W - @pos.y) * 0.6

      for p in @pieces
        p.update arguments...

      if @stepNum > 3
        for spawner in @app.machines.wadgetSpawners
          if @touches spawner
            @kill()
            return

      # for w in @app.wadgets
      #   continue if w is @
      #   continue if w.stepNum is 0
      #   continue if @direction == w.direction and (@delay>0 or w.delay>0)
      #   if @gpos.x == w.gpos.x and @gpos.y == w.gpos.y
      #     w.kill()
      #     @kill()
      #     return
      #   else if @touches w
      #     switch w.direction
      #       when LEFT, RIGHT
      #         continue if @direction in [UP,DOWN]
      #       when UP, DOWN
      #         continue if @direction in [LEFT,RIGHT]
      #     w.kill()
      #     @kill()
      #     return
      return

    kill: ->
      return if @exploding
      #@app.sfx.died.play(0.5)
      @exploding = true
      for p in @pieces
        p.exploding = true
        p.dest =
          x: p.pos.x + util.range -10, 10
          y: p.pos.y + util.range -10, 10
          r: 0#Math.random() * Math.PI
      @ttl_start = @ttl = 500
      @app.removeWadget @

  return Wadget