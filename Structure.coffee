assert = require 'assert'

exports.Set = class Set
	constructor: (characteristic) ->
		@char = characteristic
	contains: (x) ->
		@char x
	cross: (B) ->
		new Set (p) => @contains(p[0]) and B.contains(p[1])
	where: (also) ->
		new Set (x) => (@contains x) and (also x)


exports.Magma = class Magma
	constructor: (set, op) ->
		@s = set
		@o = op
	op: (x, y) ->
		assert.ok (@s.contains(x) and @s.contains(y)), 'values outside of magma'
		z = @o x, y
		assert.ok (@s.contains z), 'magma operation not closed'
		z
	pow: (x,i) ->
		assert.ok i > 0, 'power must be a positive integer'
		[1..i-1].reduce ((result, discarded) => (@op result, x)), x
	cross: (M) ->
		new Magma (@s.cross M.s), ((x, y) => [@op(x[0], y[0]), M.op(x[1], y[1])])


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
			assert.ok (z == (super @log[x][0],
			                     (super @log[x][1], y))),
			          'monoid not left-associative'
		if @log[y] != undefined
			assert.ok (z == (super (super x, @log[y][0]),
			                     @log[y][1])),
			          'monoid not right-associative'
		z
	cross: (M) ->
		z = super M
		z.i = [@i, M.i]
		z


exports.Group = class Group extends exports.Monoid
	constructor: (set, op, id, inv) ->
		super set, op, id
		@inv = inv
	invert: (x) ->
		y = @inv x
		assert.ok @op(x, y) == @i, 'inverse failed to invert'
		y
	cross: (M) ->
		z = super M
		z.invert = (p) => [@invert(p[0]), M.invert(p[1])]
		z
