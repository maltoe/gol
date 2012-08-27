require 'set'

class View
	attr_reader :minx, :miny, :area_side

	def initialize
		@minx = -5
		@miny = -5
		@area_side = 10

		@mincellx = nil
		@maxcellx = nil
		@mincelly = nil
		@maxcelly = nil
	end

	def <<(c)
		x, y = *c
		
		@mincellx = x if ! @mincellx || x < @mincellx
		@maxcellx = x if ! @maxcellx || x > @maxcellx
		@mincelly = y if ! @mincelly || y < @mincelly
		@maxcelly = y if ! @maxcelly || y > @maxcellx

		adjustView! if ! fitsInView? x, y
	end

	private

	def fitsInView?(x, y)
		x > @minx && x < @minx + @area_side && y > @miny && y < @miny + @area_side
	end

	def adjustView!
		dmaxcell = 	[ @maxcellx - @mincellx, @maxcelly - @mincelly ]

		# Grow screen if necessary.
		if dmaxcell.any? { |d| d + 10 >= @area_side }
			@area_side = dmaxcell.max + 10
		end
		
		# Move simulation to center of view.
		@minx = @mincellx - ((@area_side - dmaxcell[0]) / 2)
		@miny = @mincelly - ((@area_side - dmaxcell[1]) / 2)
	end
end

class World
	attr_reader :stable

	def initialize(view = View.new)
		@beings = Set.new
		@view = view
		@stable = true
	end

	def populate!(n, m)
		n2 = n / 2
		m.times do
			begin
				c = [rand(-n2...n), rand(-n2...n)]
			end while lives? c
			live! c
		end
	end

	def load!(s)
		s.each { |c| live! c }
	end

	def breed
		nextgen = World.new @view
		for i in 0..@view.area_side do
			for j in 0..@view.area_side do
				c = [@view.minx + i, @view.miny + j]
				n = neighbours c				
				nextgen.live! c if n === 3 || ((lives? c) && n === 2)
			end
		end
		nextgen
	end

	def to_s
		str = ""
		for i in 0..@view.area_side do
			for j in 0..@view.area_side do
				c = [@view.minx + i, @view.miny + j]
				str += (lives? c) ? "X" : "."
			end
			str += "\n"
		end
		str
	end

	protected

	def live!(c)
		@beings << c
		@view << c
		@stable = false
	end

	private

	def lives?(c)
		@beings.include? c
	end

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
		].find_all { |n| lives? n }.length
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
	]
]

puts "Game of Life in Ruby"

m = World.new
#m.populate! 10, 150
m.load! starts[1]

(0..200).each do |generation|
	system "clear"
	puts "Generation: #{ generation }"
	puts m

	break if m.stable
		
	m = m.breed
	sleep 0.2
end
