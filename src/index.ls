reloopr = ->
  @running = false
  @time = { now: 0, last: 0 }
  @fps 60
  @evt-handler = {}
  @

reloopr.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  reset: -> @time = {now: 0}
  set-time: (t) -> @time.now = t
  get-time: -> @time.now
  is-running: -> @running
  toggle: ->
    if it? => @running = !it
    if @running => @pause! else @run!
  pause: -> @running = false
  render: -> @fire \tick, @time.now
  run: (fps) ->
    if fps? => @fps fps
    if @running => return
    @running = true
    requestAnimationFrame (t) ~> @handler(@time.last = t, true)
  throttle: (v = true) -> @is-throttled = v
  fps: ->
    if !(it?) => return @_fps_val
    @_fps_val = it >? 0.01
    @_fps_delay = 1000 / @_fps_val
  handler: (t, force = false) ->
    if !@running => return
    @time.now = t
    delay = if @is-throttled => (@_fps_delay >? 1000) else @_fps_delay
    if force or (@time.now - @time.last) >= delay =>
      @time.last = t
      @render!
    requestAnimationFrame (t) ~> @handler t, false

reloopr.visibilityObserver = ->
  @list = []
  @

reloopr.visibilityObserver.prototype = Object.create(Object.prototype) <<<
  destroy: ->
    # TODO here removeEventListener
  init: ->
    @inited = true
    [h,vc] = if document.hidden? => <[hidden visibilitychange]>
    else if document.msHidden? => <[hidden visibilitychange]>
    else if document.webkiHidden? => <[webkitHidden webkitvisibilitychange]>
    else <[hidden visibilitychange]>
    document.addEventListener vc, debounce 150, (~>
      th = !!document[h]
      #console.log "visibility changed, #{if th => 'enable' else 'disable'} chart reloopr throttling."
      @list.map -> if it.throttle => it.throttle th
    ), false
  add: (o) ->
    if !@inited => @init!
    @list.push o

module.exports = reloopr
