define [
  'fragl'
  'modules/tile'
], (FRAGL, TILE) ->

  MIN_SPDX = 20
  MAX_SPDX = 80
  MIN_SPDY = 0
  MAX_SPDY = 30

  class Player extends FRAGL.Actor
    constructor: ->
      super arguments...
      @behaviors.push FRAGL.HasPhysics
      @behaviors.push TILE.HasHotspots

    width: 9
    height: 14
    init: ->
      super arguments...
      app = FRAGL.apps[0]

      @bounce = 1

      @v.x = MIN_SPDX + Math.random()*(MAX_SPDX-MIN_SPDX)
      @v.y = MIN_SPDY + Math.random()*(MAX_SPDY-MIN_SPDY)
      if Math.random() < 0.5
        @v.x *= -1
      if Math.random() < 0.5
        @v.y *= -1

      @hotspots.leftFoot = new TILE.Bottomspot @, {x:@width*0.2,y:@height-2}
      @hotspots.rightFoot = new TILE.Bottomspot @, {x:@width*0.8,y:@height-2}

      @hotspots.leftSide = new TILE.Leftspot @, {x:0,y:@height/2}
      @hotspots.rightSide = new TILE.Rightspot @, {x:@width,y:@height/2}

      @hotspots.headLeft = new TILE.Topspot @, {x:@width*0.1,y:0}
      @hotspots.headRight = new TILE.Topspot @, {x:@width*0.9,y:0}

      @anims.run = new FRAGL.Animation(
        app.gfx.player,
        9,14,
        50 / (Math.abs(@v.x)/MAX_SPDX),
        [8,9,10,11,12,13,14,15]
      )
      @anims.idle = new FRAGL.Animation(
        app.gfx.player,
        9,14,
        50,
        [0],
        false
      )
      @anim = @anims.run
      @tick = 3.14*Math.random()
      @pivot =
        x: @width/2
        y: @height

    update: ->
      super arguments...

      if @hotspots.rightFoot.didCollide or @hotspots.leftFoot.didCollide
        @grounded = true
        #@v.y = 0
      else
        @grounded = false

      if @v.x < 0
        @flipX = true
      else
        @flipX = false
      
      if Math.abs(@v.x) > 1
        @anim = @anims.run
        @anim.frameLength = 50/(Math.abs(@v.x)/MAX_SPDX)
      else
        @anim = @anims.idle

      @tick += 0.15
      #@alpha = 0.5 + 0.5*(1+Math.sin(@tick))*0.5
      #@rot = 0.3*Math.cos(@tick*2.1)
      #@scaleX = 0.5+(1+Math.cos(@tick*1.3))*0.5*2
      #@scaleY = 0.5+(1+Math.cos(@tick*1.3))*0.5*2
      
  return Player
