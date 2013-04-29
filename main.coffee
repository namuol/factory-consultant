define [
  'fragl'
  'util'
  'modules/web'
  'modules/ui'
  'wadget'
  'machines'
  'puzzles'
  'levelselect'
], (fr, util, web, ui, Wadget, mn, puzzles, LevelSelectScreen)->
  GRID_SPACING_W = 3
  GRID_SPACING_H = 3
  GRID_W = 12*3
  GRID_H = 11*3

  SCR_W = GRID_SPACING_W * GRID_W
  SCR_H = GRID_SPACING_H * (GRID_H + 3)
  SCALE = 5
  FPS = 60

  Wadget.MIN_GX = 0
  Wadget.MAX_GX = GRID_W - 1
  Wadget.MIN_GY = 3
  Wadget.MAX_GY = GRID_H - 6

  WHITE = Wadget.WHITE
  BLACK = Wadget.BLACK
  RED = Wadget.RED

  split_to_lines = (str, max_width) ->
    lines = []
    words = str.split(' ')
    current_line = ''
    for word in words
      if current_line.length + word.length > max_width
        lines.push current_line
        current_line = word + ' ' 
      else
        current_line += word + ' ' 
    lines.push current_line
    return lines

  class MsgScreen extends fr.Actor
    width: SCR_W
    height: SCR_H
    drawOrder: 999
    msgs: [
      '''
      Hey there! This is some fancy test example text.^
      I'm not really sure what it's going to look like.^
      Hopefully it works.
      '''
      '''
      Second test screen.
      '''
    ]
    init: ->
      @behaviors.push ui.MouseInteractive
      # OVERLAY:
      @sheet = new fr.TextureGrid @app.gfx.gfx, 9, 9
      @anim = @sheet.anim 0, 50, false
      @pos.x = 0
      @pos.y = 0
      @scaleX = SCR_W/9
      @scaleY = SCR_H/9
      @currentMessageNum = 0
      @setMessage(@msgs[@currentMessageNum])
      super
    setMessage: (msg) ->
      paragraphs = msg.replace(new RegExp('\n','g'),' ').split('^')
      wrappedParagraphs = []
      for p in paragraphs
        wrappedParagraphs.push split_to_lines(p, Math.floor(SCR_W/4)-1).join('\n').replace(new RegExp(" +","g"), ' ')
      str = wrappedParagraphs.join('\n')
      @text = new fr.TextString
        font: @app.font
        alignment: 'center'
        string: str
        pos:
          x: SCR_W / 2
          y: SCR_H / 2

    draw: ->
      super arguments...
      @text.draw arguments...
    onclick: ->
      ++@currentMessageNum
      if @currentMessageNum >= @msgs.length
        @dead = true
      else
        @setMessage @msgs[@currentMessageNum]

  class TopBar extends fr.Actor
    width: SCR_W
    height: 10
    drawOrder: -1
    init: ->
      sheet = new fr.TextureGrid @app.gfx.ui, SCR_W, 9
      @anim = sheet.anim 2
    hover: (higlight=true) ->

  class BottomBar extends fr.Actor
    width: SCR_W
    height: 900
    drawOrder: -1
    init: ->
      sheet = new fr.TextureGrid @app.gfx.ui, SCR_W, 18
      @anim = sheet.anim 0
    hover: (higlight=true) ->

  class TargetWadget extends Wadget
    init: ->
      super arguments...
    onmouseover:->
    #   for p in @pieces
    #     p.behaviors.push ui.MouseInteractive
    #     p.onclick = ->
    #       @color = (@color + 1) % @app.colors.length
    #       @anim = @app.colors[@color]
    # update: ->
    #   for p in @pieces
    #     p.update arguments...

  class Button extends fr.Actor
    width: 9
    height: 9
    gridW: 9
    gridH: 9
    gfx: 'gfx'
    enable: ->
      @visible = true
      @disabled = false
    disable: ->
      @visible = false
      @hoverIndicator.visible = false
      @disabled = true
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
    onmousedown: ->
      @hoverIndicator.alpha = 0.5
    onmouseup: ->
      @hoverIndicator.alpha = 1
    update: ->
      super arguments...

      if @hoverIndicator.visible
        @hoverIndicator.pos = @pos
        @hoverIndicator.anim.offset = @anim.offset

  class GoButton extends Button
    frames: [14]
    onclick: ->
      @app.go()

  class StopButton extends Button
    frames: [15]
    onclick: ->
      @app.stop()

  class SpeedupButton extends Button
    frames: [20]
    toggled: false
    alpha: 0.5
    onclick: ->
      @toggled = !@toggled
      if @toggled
        @app.speedUp()
        @alpha = 1
      else
        @app.slowDown()
        @alpha = 0.5
    update: ->
      super arguments...
      @visible = @app.going
      @disabled = !@app.going
  
  class HelpButton extends Button
    frames: [19]
    onclick: ->
      fr.log @app.msgScreen
      if not @app.msgScreen?
        @app.addMsgScreen()

  class BackButton extends Button
    frames: [29]
    onclick: ->
      @app.stop()
      setTimeout =>
        @app.levelSelect()
      , 0

  class NextButton extends Button
    frames: [39]
    onclick: ->
      @app.stop()
      setTimeout =>
        @app.loadLevel @app.currentLevelNum+1
      , 0
    update: ->
      super arguments...
      if @disabled
        @alpha = 0.5
      else
        @alpha = 1

  class Meter extends fr.Actor
    targetScale: 0
    scaleSpeed: 0
    init: ->
      super
      @sheet = new fr.TextureGrid @app.gfx.gfx, 3, 9
      @left = new fr.Actor
        pos:
          x: @pos.x
          y: @pos.y
        drawOrder: @drawOrder
        anim: @sheet.anim 90, 50, false
      @center = new fr.Actor
        pos:
          x: @pos.x + 3
          y: @pos.y
        scaleX: (@width-9)/3
        drawOrder: @drawOrder
        anim: @sheet.anim 91, 50, false
      @right = new fr.Actor
        pos:
          x: @pos.x + @width - 6
          y: @pos.y
        drawOrder: @drawOrder
        anim: @sheet.anim 92, 50, false
      @fill = new fr.Actor
        pos:
          x: @pos.x
          y: @pos.y
        scaleX: 0
        drawOrder: @drawOrder-0.1
        anim: @sheet.anim 93, 50, false
    getDrawables: -> [@left, @center, @right, @fill]
    update: ->
      super arguments...
      if !(@app.machines.wadgetCatchers? and @app.machines.wadgetCatchers.length>0)
        return
      count = @app.machines.wadgetCatchers[0].streak
      if !@app.beat and count >= @app.requiredWadgetCount
        @app.beatLevel()
      targetScale = Math.min ((@width-3)/3), (((@width-3)/3) * (count / @app.requiredWadgetCount))
      targetSpeed = targetScale - @fill.scaleX
      @scaleSpeed += (targetSpeed - @scaleSpeed) * 0.1
      @fill.scaleX += @scaleSpeed

      if Math.abs(@scaleSpeed) < 0.1
        @scaleSpeed = 0

      if @fill.scaleX < 0
        @fill.scaleX = 0

      if @fill.scaleX > (@width-3)/3
        @fill.scaleX = (@width-3)/3

  class MyApp extends web.WebApp
    requiredWadgetCount: 8
    gfx:
      gfx: 'assets/gfx.png'
      ui: 'assets/ui.png'
      font: 'assets/tom-thumb-new.png'
    sfx:
      # Shorthand multi-file load:
      bip: ['assets/bip.ogg', 'assets/bip.mp3', 'assets/bip.m4a']
      good: ['assets/good.ogg', 'assets/good.mp3', 'assets/good.m4a']
      spawn: ['assets/spawn.ogg', 'assets/spawn.mp3', 'assets/spawn.m4a']
      bloop: ['assets/bloop.ogg', 'assets/bloop.mp3', 'assets/bloop.m4a']
      beatlevel: ['assets/beatlevel.ogg', 'assets/beatlevel.mp3', 'assets/beatlevel.m4a']
      pickup: ['assets/pickup.ogg', 'assets/pickup.mp3', 'assets/pickup.m4a']
      putdown: ['assets/putdown.ogg', 'assets/putdown.mp3', 'assets/putdown.m4a']
      died: 
        paths: ['assets/died.ogg', 'assets/died.mp3', 'assets/died.m4a']
        numChannels: 1
      omnom: ['assets/omnom.ogg', 'assets/omnom.mp3', 'assets/omnom.m4a']
    allowSfxFailures: true
    machines: {}
    badMachines: []
    isLevelUnlocked: (num) ->
      return true if num is 0
      return false if num >= puzzles.length

      unlockedLevels = JSON.parse(localStorage.getItem('unlockedLevels')) or []
      return (puzzles[num].name) in unlockedLevels
    beatLevel: ->
      @beat = true
      @sfx.beatlevel.play(0.8)
      
      unlockedLevels = JSON.parse(localStorage.getItem('unlockedLevels')) or []
      next = puzzles[@currentLevelNum+1]
      if next?
        if not (next.name in unlockedLevels)
          unlockedLevels.push next.name
          localStorage.setItem 'unlockedLevels', JSON.stringify(unlockedLevels)
        @nextButton.disabled = false if @nextButton?

      msg = util.choose [
        'Well Done!'
        'Fantastic!'
        'Looking good, keep up the great work!'
        'Amazing work.'
        'Wow! Where did you learn to do that?'
      ]
      @addActor new MsgScreen
        msgs: [msg]
    go: ->
      @going = true
      @goButton.disable()
      @stopButton.enable()
      if @msgScreen?
        @msgScreen.dead = true
        @msgScreen = null
    stop: ->
      @going = false
      @goButton.enable() if @goButton?
      @stopButton.disable() if @stopButton?
      for own k,mt of @machines
        for m in mt
          m.reset() if m.reset
      for w in @wadgets
        w.dead = true
        @removeWadget w
    addMachine: (m) ->
      @addActor m
      if not @machines[m.mtype]?
        @machines[m.mtype] = []
      @machines[m.mtype].push m
    removeMachine: (m) ->
      if @machines[m.mtype]?
        if (m in @machines[m.mtype])
          m.dead = true
          @badMachines.push m
    wadgets: []
    badWadgets: []
    addWadget: (w) ->
      @wadgets.push w
      @addActor w
    removeWadget: (w) ->
      if not (w in @badWadgets)
        @badWadgets.push w
    addMsgScreen: ->
      msgs = puzzles[@currentLevelNum].msgs
      if msgs
        @msgScreen = new MsgScreen
          msgs: msgs
        @addActor @msgScreen
    clearEverything: ->
      @stop()
      @actors = []

      @machines = 
        wadgetSpawners: []

      @drawTarget.drawables = []
    reset: ->
      @beat = false

      @clearEverything()

      if not @isLevelUnlocked @currentLevelNum+1
        @addMsgScreen()

      @target = new TargetWadget
       gpos:
         x: 6
         y: 0
      @addActor @target

      @meter = new Meter
        pos:
          x: @target.pos.x + 9
          y: 0
        width: SCR_W-(@target.pos.x+6)-27
      @addActor @meter

      @addActor new BackButton
        pos:
          x: SCR_W - 9*3
          y: 0

      @nextButton = new NextButton
        disabled: not @isLevelUnlocked(@currentLevelNum+1)
        pos:
          x: SCR_W - 9*2
          y: 0
      @addActor @nextButton
      @addActor new HelpButton
        pos:
          x: SCR_W - 9
          y: 0

      @addMachine new mn.MachineSpawner
        machineType: mn.BlackPainter
        pos:
          x: 9*0
          y: SCR_H-18
      @addMachine new mn.MachineSpawner
        machineType: mn.RedPainter
        pos:
          x: 9*1
          y: SCR_H-18
      @addMachine new mn.MachineSpawner
        machineType: mn.WhitePainter
        pos:
          x: 9*2
          y: SCR_H-18

      @addMachine new mn.MachineSpawner
        machineType: mn.LeftArrow
        pos:
          x: 9*3
          y: SCR_H-18
      @addMachine new mn.MachineSpawner
        machineType: mn.RightArrow
        pos:
          x: 9*4
          y: SCR_H-18
      @addMachine new mn.MachineSpawner
        machineType: mn.UpArrow
        pos:
          x: 9*5
          y: SCR_H-18
      @addMachine new mn.MachineSpawner
        machineType: mn.DownArrow
        pos:
          x: 9*6
          y: SCR_H-18

      @addMachine new mn.MachineSpawner
        machineType: mn.HorizontalSwitchArrow
        pos:
          x: 9*7
          y: SCR_H-18
      @addMachine new mn.MachineSpawner
        machineType: mn.VerticalSwitchArrow
        pos:
          x: 9*8
          y: SCR_H-18

      @addMachine new mn.MachineSpawner
        machineType: mn.Delay
        pos:
          x: 9*11
          y: SCR_H-18

      @deleter = new BottomBar
        pos:
          x: 0
          y: SCR_H - 18
      @addActor @deleter

      @top = new TopBar
        pos:
          x: 0
          y: 0
      @addActor @top

      @goButton = @addActor new GoButton
        pos:
          x: 0
          y: 0

      @stopButton = @addActor new StopButton
        pos:
          x: 0
          y: 0
      @addActor new SpeedupButton
        pos:
          x: 9
          y: 0
      @stop()
    getRate: ->
      if @machines.wadgetSpawners? and @machines.wadgetSpawners.length > 0
        return @machines.wadgetSpawners[0].rate
      else
        return 3
    init: (container) ->
      super arguments...

      @input.mapKey [fr.K_ESC], 'stop'
      @input.mapKey [fr.K_SPACE], 'go'
      @input.mapKey [fr.K_RIGHT], 'nextLevel'
      @input.mapKey [fr.K_LEFT], 'prevLevel'
      #@input.mapKey [fr.K_D], 'designMode'
      @input.mapKey [fr.K_M], 'mute'

      @sheet = new fr.TextureGrid @gfx.gfx, 3, 3
      @colors = []
      @colors[WHITE] = @sheet.anim 15, 50, false
      @colors[BLACK] = @sheet.anim 16, 50, false
      @colors[RED] = @sheet.anim 17, 50, false

      @font = new fr.Font @, @gfx.font, 4,6
      $(container).width(SCR_W * SCALE)
      $(container).height(SCR_H * SCALE)
      @drawTarget.bgColor = 'transparent'
      if not @isLevelUnlocked(1)
        @loadLevel 0
      else
        @levelSelect()

    levelSelect: ->
      @clearEverything()
      @addActor new LevelSelectScreen

    loadLevel: (num) ->
      @stop() if @going

      @currentLevelNum = num

      @reset()
      lvl = puzzles[num]
      tools = new Array lvl.tools...
      for ms in @machines.machineSpawners
        len = tools.length
        tools = util.arrayRemove tools, ms.machineType
        count = len - tools.length
        ms.remaining = count
      gy=0
      while gy < lvl.objects.length
        gx=0
        row = lvl.objects[gy]
        while gx < row.length
          machineType = row[gx]

          if machineType
            props =
              levelDisabled: true
              disabled: true
              pos:
                x: gx * GRID_SPACING_W * 3 # *3 HACK -- levels originally on 9px-width grid.
                y: gy * GRID_SPACING_H * 3 

            if typeof machineType is 'string'
              for own k,v of lvl.details[machineType]
                continue if k is 'mtype'
                props[k] = v
              machineType = lvl.details[machineType].mtype

            @addMachine new machineType(props)
          ++gx
        ++gy

      i=0
      for color in lvl.target
        @target.pieces[i].color = color
        ++i

      for spawner in @machines.wadgetSpawners
        spawner.rate = lvl.rate
      return
    tick: 0
    designMode: ->
      @designing = !@designing
    goingTimeScale: 1
    speedUp: ->
      @goingTimeScale = 5
    slowDown: ->
      @goingTimeScale = 1
    update: ->
      if !@going
        @timeScale = 1
      else
        @timeScale = @goingTimeScale
        if ++@tick % (FPS*0.25) == 0
          #@sfx.bip.play()
          for w in @wadgets
            w.step()
          for own k,mt of @machines
            for m in mt
              m.step() if m.step

      super arguments...

      if @msgScreen? and @msgScreen.dead
        @msgScreen = null

      if @actions.go.hit()
        if @going
          @stop()
        else
          @go()

      if @actions.nextLevel.hit()
        @loadLevel util.mod (@currentLevelNum + 1), puzzles.length

      if @actions.prevLevel.hit()
        @loadLevel util.mod (@currentLevelNum - 1), puzzles.length

      # if @actions.designMode.hit()
      #   @designMode()
      if @actions.mute.hit()
        @muted = !@muted
      for a in @badWadgets
        @wadgets.splice @wadgets.indexOf(a), 1
      @badWadgets = []

      for a in @badMachines
        @machines[a.mtype].splice @machines[a.mtype].indexOf(a), 1
      @badMachines = []

  app = new MyApp SCR_W, SCR_H, FPS, SCALE, [web.ScaledCanvasDrawTarget, web.CanvasDrawTarget]
  app.run 'container'
  app.puzzles = puzzles
  window.app = app