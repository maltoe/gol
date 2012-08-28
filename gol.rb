require 'set'

class RingBuffer < Array
	def initialize(size)
		super size
		@ring_size = size
	end

	def <<(o)
		shift if length == @ring_size
		push o
	end
end

class View
	attr_reader :minx, :miny, :area_side

	def initialize
		@minx = -5
		@miny = -5
		@area_side = 10
	end

	def update!(beings)
		adjustView! beings if beings.any? { |c| ! fitsInView? c }
	end

	private

	def fitsInView?(c)
		x, y = *c
		x > @minx && x < @minx + @area_side && y > @miny && y < @miny + @area_side
	end

	def adjustView!(beings)
		xs = beings.map { |c| c[0] }
		ys = beings.map { |c| c[1] }
		mincellx = xs.min
		mincelly = ys.min
		dmaxcell = 	[ xs.max - mincellx, ys.max - mincelly ]

		# Grow screen if necessary.
		if dmaxcell.any? { |d| d + 10 >= @area_side }
			@area_side = dmaxcell.max + 10
		end
		
		# Move simulation to center of view.
		@minx = mincellx - ((@area_side - dmaxcell[0]) / 2)
		@miny = mincelly - ((@area_side - dmaxcell[1]) / 2)
	end
end

class World

	def initialize(beings)
		@history = RingBuffer.new(4)
		@beings = beings || Set.new
		@view = View.new()
		@view.update! beings if beings
	end

	def self.random(n, m)
		beings = []
		n2 = n / 2
		m.times do
			begin
				c = [rand(-n2...n), rand(-n2...n)]
			end while beings.include? c
			beings << c
		end
		World.new beings
	end

	def breed!
		nextgen = Set.new
		for i in 0..@view.area_side do
			for j in 0..@view.area_side do
				c = [@view.minx + i, @view.miny + j]
				n = neighbours c
				nextgen << c if n === 3 || ((@beings.include? c) && n === 2)
			end
		end

		@history << @beings
		@beings = nextgen
		@view.update! @beings
	end

	def stable?
		@beings.length == 0 || @history.any? { |h| h == @beings }
	end

	def to_s
		str = ""
		for i in 0..@view.area_side do
			for j in 0..@view.area_side do
				c = [@view.minx + i, @view.miny + j]
				str += (@beings.include? c) ? "X" : "."
			end
			str += "\n"
		end
		str
	end

	private

	def neighbours(c)
		x, y = *c
		[
			[x - 1, y - 1],
			[x, y - 1],
			[x + 1, y - 1],
			[x - 1, y],
			[x + 1, y],
			[x - 1, y + 1],
			[x, y + 1],
			[x + 1, y + 1]
		].find_all { |n| @beings.include? n }.length
	end
end

starts = [
	# F-pentomino
	[
		[0, -1],
		[1, -1],
		[-1, 0],
		[0, 0],
		[0, 1]
	],
	# Diehard
	[
		[3, -1],
		[-3, 0],
		[-2, 0],
		[-2, 1],
		[2, 1],
		[3, 1],
		[4, 1]
	],
	# Acorn
	[
		[-2, -1],
		[0, 0],
		[-3, 1],
		[-2, 1],
		[1, 1],
		[2, 1],
		[3, 1]
	],
	# Glider
	[
		[0, -1],
		[1, 0],
		[-1, 1],
		[0, 1],
		[1, 1]
	],
	# Stable block
	[
		[0, 0],
		[0, 1],
		[1, 0],
		[1, 1]
	]
]

puts "Game of Life in Ruby"

#m = World.new starts[3]
m = World.random 10, 150

(0..200).each do |generation|
	system "clear"
	puts "Generation: #{ generation }"
	puts m

	if m.stable?
		puts "Still life or oscillator detected."
		break
	end
		
	m.breed!
	sleep 0.2
end
