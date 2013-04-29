define [
  'fragl'
  'util'
  'modules/ui'
  'wadget'
], (fr, util, ui, Wadget) ->

  mn = {}

  MAX_WADGETS = 64

  WHITE = Wadget.WHITE
  BLACK = Wadget.BLACK
  RED = Wadget.RED
  class mn.Machine extends fr.Actor
    gridW: 9
    gridH: 9
    gfx: 'gfx'
    draggable: true
    getDrawables: -> [@hoverIndicator, @]
    init: ->
      @sheet = new fr.TextureGrid @app.gfx[@gfx], @gridW, @gridH
      @anim = @sheet.anim @frames, 50
      @behaviors.push ui.MouseInteractive
      @hoverIndicator = new fr.Actor
        visible: false
        anim: @sheet.anim 13, 50, false
        drawOrder: @drawOrder+1
      super
    onmouseover: ->
      @hoverIndicator.visible = true
    onmouseout: ->
      @hoverIndicator.visible = false
    update: ->
      @disabled = @levelDisabled or @app.going

      prevPos =
        x: @pos.x
        y: @pos.y

      super arguments...

      if @hoverIndicator.visible
        @hoverIndicator.pos = @pos
        @hoverIndicator.anim.offset =
          x: @anim.offset.x
          y: @anim.offset.y
    onsnap: ->
      @parent.visible = true if @parent?

      @app.sfx.putdown.play(0.45)
      if @touches @app.deleter
        @app.deleter.hover()
        @app.removeMachine @
        ++@parent.remaining if @parent
      else
        @app.deleter.hover(false)
        @shouldDelete = false
    ondrag: ->
      @app.sfx.pickup.play(0.35)

  class mn.MachineSpawner extends mn.Machine
    mtype: 'machineSpawners'
    drawOrder: 5
    width: 9
    height: 9
    remaining: 0
    disabled: true
    constructor: (props) ->
      props.gfx = props.machineType::gfx
      props.gridW = props.machineType::gridW
      props.gridH = props.machineType::gridH
      props.frames = props.machineType::frames
      super props
    init: ->
      super
      @count = new fr.TextString
        font: @app.font
        alignment: 'center'
        string: ''+@remaining
        pos:
          x: @pos.x+@width/2
          y: @pos.y+13
    ondrag: ->
      mx = @app.input.worldMouse.x
      my = @app.input.worldMouse.y
      @visible = false
      m = new @machineType
        parent: @
        pos:
          x: @pos.x - (if @machineType::touchOffsetX? then @machineType::touchOffsetX else 0)
          y: @pos.y - (if @machineType::touchOffsetY? then @machineType::touchOffsetY else 0)
      m.app = @app
      m.init()
      m.startDragging mx,my, @_button
      @app.addMachine m
      --@remaining
    getDrawables: -> [@, @count, @hoverIndicator]
    update: ->
      super arguments...
      @count.string = ''+@remaining
      if @app.designing
        @levelDisabled = false
      else
        @levelDisabled = @remaining <= 0

      if @levelDisabled
        @hoverIndicator.visible = false
        @visible = false
        @count.visible = false
        @alpha = 0
      else
        @visible = true
        @count.visible = true
        @count.alpha = 1
        @alpha = 1

      if @disabled
        @count.alpha = 0.5
        @alpha = 0.5

  UP = Wadget.UP
  DOWN = Wadget.DOWN
  LEFT = Wadget.LEFT
  RIGHT = Wadget.RIGHT

  class mn.Arrow extends mn.Machine
    mtype: 'arrows'
    toggled: true
    width: 9
    height: 9
    dragSnap: 3
    drawOrder: -1
    init: ->
      @collisionObj = {
        pos:
          x:@pos.x
          y:@pos.y
        width: 2.9
        height: 2.9
      }
      super
    update: ->
      super arguments...
      @collisionObj.pos.x = @pos.x
      @collisionObj.pos.y = @pos.y

  class mn.UpArrow extends mn.Arrow
    frames: [1]
    direction: UP
  class mn.DownArrow extends mn.Arrow
    frames: [2]
    direction: DOWN
    init: ->
      super
      @anim.offset.y = 1
    update: ->
      super arguments
      if @hoverIndicator.visible
        @hoverIndicator.anim.offset.y = 0
  class mn.LeftArrow extends mn.Arrow
    frames: [3]
    direction: LEFT
  class mn.RightArrow extends mn.Arrow
    frames: [4]
    direction: RIGHT

  class mn.Delay extends mn.Machine
    mtype: 'delays'
    width: 9
    height: 9
    dragSnap: 3
    frames: [8]
    drawOrder: 0
    init: ->
      @collisionObj = {
        pos:
          x:@pos.x
          y:@pos.y
        width: 2.9
        height: 2.9
      }
      super
    update: ->
      super arguments...
      @collisionObj.pos.x = @pos.x
      @collisionObj.pos.y = @pos.y

  class mn.ToggleArrow extends mn.Arrow
    toggled: true
    rate: 2
    tick: 0
    init: ->
      super
      @anims.idle = @anim
      @anims.toggled = @sheet.anim [@frames[0]+4, @frames[0]], 50
    reset: ->
      @tick = 0
      @toggled = false
      @anim = @anims.idle
    step: ->
      if (@tick % @app.getRate() == 0)
        @toggled = !@toggled

      if @toggled
        @anim = @anims.toggled
      else
        @anim = @anims.idle

      ++@tick

  class mn.UpToggle extends mn.ToggleArrow
    frames: [21]
    direction: UP
  class mn.DownToggle extends mn.ToggleArrow
    frames: [22]
    direction: DOWN
  class mn.LeftToggle extends mn.ToggleArrow
    frames: [23]
    direction: LEFT
  class mn.RightToggle extends mn.ToggleArrow
    frames: [24]
    direction: RIGHT

  class mn.SwitchArrow extends mn.Arrow
    rate: 3
    tick: 0
    switched: false
    reset: ->
      @tick = 0
      @direction = @nonSwitchedDirection
      @anim = @anims.notSwitched
    init: ->
      super
      @anims.up = @sheet.anim 25, 50, false
      @anims.down = @sheet.anim 26, 50, false
      @anims.left = @sheet.anim 27, 50, false
      @anims.right = @sheet.anim 28, 50, false
    step: ->
      if (@tick % @app.getRate() == 0)
        @switched = !@switched
        if @switched
          @anim = @anims.switched
          @direction = @switchedDirection
        else
          @anim = @anims.notSwitched
          @direction = @nonSwitchedDirection
      ++@tick

  class mn.HorizontalSwitchArrow extends mn.SwitchArrow
    frames:[27]
    nonSwitchedDirection: LEFT
    switchedDirection: RIGHT
    init: ->
      super
      @anims.notSwitched = @anims.left
      @anims.switched = @anims.right

  class mn.VerticalSwitchArrow extends mn.SwitchArrow
    frames:[25]
    nonSwitchedDirection: UP
    switchedDirection: DOWN
    init: ->
      super
      @anims.notSwitched = @anims.up
      @anims.switched = @anims.down

  class mn.Painter extends mn.Machine
    mtype: 'painters'
    width: 3
    height: 3
    touchWidth: 9
    touchHeight: 9
    touchOffsetX: -3
    touchOffsetY: -3
    dragSnap: 3
    gridW: 9
    gridH: 9
    drawOrder: 3
    init: ->
      super arguments...
      @anim.offset.x = @touchOffsetX
      @anim.offset.y = @touchOffsetY

  class mn.WhitePainter extends mn.Painter
    frames: [10]
    color: WHITE
    paintsOver: [RED,BLACK]

  class mn.BlackPainter extends mn.Painter
    frames: [11]
    color: BLACK
    paintsOver: [WHITE,RED]

  class mn.RedPainter extends mn.Painter
    frames: [12]
    color: RED
    paintsOver: [WHITE]

  class mn.WadgetSpawner extends mn.Machine
    mtype: 'wadgetSpawners'
    width: 9
    height: 9
    dragSnap: 3
    frames: [6]
    rate: 3
    drawOrder: 5
    init: ->
      super arguments...
      @anims.idle = @anim
      @anims.spawning = @sheet.anim [18], 50
      @tick = 0
    update: ->
      super arguments...
      @levelDisabled = !@app.designing
    reset: ->
      @anim = @anims.idle
      @tick = 0
    step: ->
      if (@tick % @rate == 0) and @app.wadgets.length < MAX_WADGETS
        @anim = @anims.spawning
        @app.sfx.bip.play(0.5)
        @app.addWadget new Wadget
          gpos:
            x:Math.floor(@pos.x/3)
            y:Math.floor(@pos.y/3)
          direction:RIGHT
      else
        @anim = @anims.idle
      ++@tick

  class mn.WadgetCatcher extends mn.Machine
    mtype: 'wadgetCatchers'
    width: 9
    height: 9
    dragSnap: 3
    frames: [7]
    drawOrder: 5
    streak: 0
    reset: ->
      @streak = 0
    init: ->
      super
      @anims.fail = @sheet.anim [16, 7], 400, false
      @anims.success = @sheet.anim [17, 7], 400, false
      @collisionObj = {
        pos:
          x:@pos.x
          y:@pos.y
        width: 2.9
        height: 2.9
      }
    update: ->
      super arguments...
      @levelDisabled = !@app.designing
      @collisionObj.pos.x = @pos.x
      @collisionObj.pos.y = @pos.y
    catchWadget: (w) ->
      i=0
      success = true
      for piece in (@target or @app.target).pieces
        if w.pieces[i].color != piece.color
          success = false
          break
        ++i
      if success
        @anim = @anims.success
        @app.sfx.good.play(0.5)
        ++@streak
      else
        @app.sfx.putdown.play(0.7)
        @anim = @anims.fail
        @streak = 0
      @anim.reset()

  return mn