assert = require 'assert'

exports.Set = class Set
  constructor: (characteristic, eq = (x,y) -> x == y) ->
    @char = characteristic
    @eq = eq
  contains: (x) ->
    @char x
  cross: (B) ->
    new Set ( (p) => @contains(p[0]) and B.contains(p[1]) ), ( (p,q) => (@eq p[0], q[0]) and (B.eq p[1], q[1]) )
  where: (also) ->
    new Set (x) => (@contains x) and (also x)

exports.Function = (f, dom, ran) ->
  ret = (xs...) ->
    assert.ok (dom.contains x), "argument #{i+1} outside function domain" for x, i in xs
    y = f xs...
    assert.ok (ran.contains y), 'function lands outside range'
    y
  ret.dom = dom
  ret.ran = ran

exports.Magma = class Magma
  constructor: (set, op) ->
    @set = set
    @o = exports.Function ( (p) -> op p[0], p[1] ), (@set.cross @set), @set
  op: (x, y) ->
    @o [x, y]
  pow: (x, i) ->
    assert.ok i > 0, 'power must be a positive integer'
    [1..i-1].reduce ((result, discarded) => (@op result, x)), x
  cross: (M) ->
    new Magma (@set.cross M.set), ((x, y) => [@op(x[0], y[0]), M.op(x[1], y[1])])

exports.Monoid = class Monoid extends exports.Magma
  constructor: (set, op, id) ->
    super set, op
    assert.ok (set.contains id), 'set does not contain identity'
    @i = id
    @log = []
  op: (x, y) ->
    z = super x, y
    @log[z] = [x, y]
    assert.ok (@i != x or z == y), 'monoid left-identity failed'
    assert.ok (@i != y or z == x), 'monoid right-identity failed'
    if @log[x] != undefined
      assert.ok (z == (super @log[x][0], (super @log[x][1], y))),
        'monoid not left-associative'
    if @log[y] != undefined
      assert.ok (z == (super (super x, @log[y][0]), @log[y][1])),
        'monoid not right-associative'
    z
  cross: (M) ->
    z = super M
    z.i = [@i, M.i]
    z

exports.Group = class Group extends exports.Monoid
  constructor: (set, op, id, inv) ->
    super set, op, id
    @inv = exports.Function inv, @set, @set
  invert: (x) ->
    y = @inv x
    assert.ok @op(x, y) == @i, 'inverse failed to invert'
    y
  cross: (M) ->
    z = super M
    z.invert = (p) => [@invert(p[0]), M.invert(p[1])]
    z
