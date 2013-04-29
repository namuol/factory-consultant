define [
  'fragl'
  'util'
  'machines'
  'wadget'
], (fr, util, mn, Wadget) ->

  W = Wadget.WHITE
  B = Wadget.BLACK
  R = Wadget.RED

  LA = mn.LeftArrow
  RA = mn.RightArrow
  UA = mn.UpArrow
  DA = mn.DownArrow

  LT = mn.LeftToggle
  RT = mn.RightToggle
  UT = mn.UpToggle
  DT = mn.DownToggle
  
  DE = mn.Delay

  WP = mn.WhitePainter
  BP = mn.BlackPainter
  RP = mn.RedPainter

  SS = mn.WadgetSpawner
  EE = mn.WadgetCatcher

  basics =
    name: 'basics'
    msgs: [
      """
      We're glad you're willing to
      help us out right now.
      """
      """
      Our last consultant left us without warning, and now our
      factory is in shambles.
      """
      """
      The orange box on the factory floor
      is the wadget templater.^^

      It creates usable
      wadget templates from raw materials and spits
      them out to the right.
      """
      """
      The blue box is the wadget collector.^^
      I need you to make sure finished wadgets
      make their way into that box.
      """
      """
      The schematic for the desired wadget is
      always centered above the factory floor
      for your reference.
      """
      """
      Drag machine parts from the bottom of the
      screen onto the factory floor.^^

      Every wadget factory has a strict budget,
      so you will have to make the most of what
      you have!
      """
      """
      To get you started, I'm 
      assigning you to our simplest
      wadget: sticks.^^
      """
      """
      The only part you need for this is a single
      "painter".^^
      Painters dye any cells of a wadget they come
      into contact with.^^
      Therefore, be sure to place them precisely!
      """
      """
      To test your design, press the "Play" button
      on the top-left, or press SPACE.^^

      Good luck!
      """
    ]
    par: 1
    rate: 6
    tools: [
      BP
    ]
    target: [
      W,W,W
      B,B,B
      W,W,W
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0, SS,  0,  0,  0,  0,  0,  0, EE,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  tee =
    name: 'tee'
    par: 2
    rate: 9
    tools: [BP,BP,DA]
    target: [
      B,B,B
      W,B,W
      W,B,W
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0, SS,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0, EE,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  belt =
    name: 'belt'
    par: 2
    rate: 6
    tools: [BP,WP,RP,UA,LA]
    target: [
      W,W,W
      B,R,B
      W,W,W
    ]
    msgs: [
      '''
      Apparently kids love belts with red buckles.^^
      It's the latest thing. I don't understand it, 
      but they sell faster than we can produce them!^^
      '''
      '''
      The trouble is, red paint can only be seen if it's
      painted over white.^^

      I'm sure you can figure it out.
      '''
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0, EE,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0, SS,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  first_aid =
    name: 'first aid'
    par: 2
    rate: 9
    tools: [RP,LA,RA,UA,DA]
    target: [
      W,R,W
      R,R,R
      W,R,W
    ]
    msgs: [
      '''
      First aid kits are always in demand.^^
      I'm not sure why. People are clumsy, I guess.
      '''
      '''
      Unfortunately, red paint is expensive, so you will
      need to make them with only one red painter.
      '''
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0, EE,  0,  0,  0]
      [ 0,  0, SS,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  donut =
    name: 'donut'
    par: 2
    rate: 9
    tools: [RP,LA,UA,DA]
    msgs: [
      '''
      Ever wonder where the donut hole goes?^^
      Perhaps it never existed...
      '''
    ]
    target: [
      R,R,R
      R,W,R
      R,R,R
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0, EE,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0, SS,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  beret =
    name: 'beret'
    par: 2
    rate: 9
    tools: [BP,RP,WP,LA,RA,UA,DA]
    msgs: [
      '''
      For such simple looking hats, berets are particularly
      difficult to fabricate.
      '''
    ]
    target: [
      W,W,W
      W,B,W
      R,R,R
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0, SS,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0, EE,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  companion =
    name: 'companion'
    par: 2
    rate: 9
    tools: [BP,BP,BP,BP,WP,WP,WP,WP,RP,LA,RA,UA,DA]
    msgs: [
      '''
      I don't know what a "companion cube" is, but
      the kids can't buy enough of them!
      '''
    ]
    target: [
      W,B,W
      B,R,B
      W,B,W
    ]
    objects: [
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0, SS,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0, EE,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
      [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]
    ]

  puzzles = [
    basics
    tee
    first_aid
    belt
    donut
    beret
    companion
  ]
  
  return puzzles