assert = require 'assert'

exports.Set = class Set
	constructor: (characteristic) ->
		@char = characteristic
	contains: (x) ->
		@char x
	cross: (B) ->
		new Set (p) => @contains(p[0]) and B.contains(p[1])


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
	op: (x, y) ->
		z = super x, y
		assert.ok (@i != x or z == y), 'monoid left-identity failed'
		assert.ok (@i != y or z == x), 'monoid right-identity failed'
		z
	cross: (M) ->
		z = super M
		z.i = [@i, M.i]
		z
