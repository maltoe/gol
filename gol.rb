class World
	def initialize(area_side = 10)
		@beings = []
		@area_side = area_side
	end

	def populate!(n, m)
		n2 = n / 2
		m.times do
			c = [rand(-n2...n), rand(-n2...n)] while lives? c
			live! c
		end
	end

	def load!(s)
		s.each { |c| live! c }
	end

	def vibrant?
		! @beings.empty?
	end

	def breed
		nextgen = World.new @area_side
		s2 = @area_side / 2
		for i in -s2...s2 do
			for j in -s2...s2 do
				c = [i, j]
				n = neighbours c				
				nextgen.live! c if n === 3 || ((lives? c) && n === 2)
			end
		end
		nextgen
	end

	def to_s
		s2 = @area_side / 2
		str = ""
		for i in -s2...s2 do
			for j in -s2...s2 do
				str += (lives? [i, j]) ? "X" : "."
			end
			str += "\n"
		end
		str
	end

	protected

	def live!(c)
		@beings << c

		while ! fitsInArea? c do
			growArea!
		end
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

	def fitsInArea?(c)
		# -1 to include all (possible) neighbours.
		x, y = *c
		s2 = @area_side / 2 - 1
		x >= -s2 && x < s2 && y >= -s2 && y < s2
	end

	def growArea!
		puts "Resizing area."
		@area_side += 10
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

m = World.new
#m.populate! 20, 50
m.load! starts[1]

puts "Game of Life in Ruby"

generation = 0
while generation <= 200 && m.vibrant? do
	sleep 0.3
	system "clear"
	puts "Generation: #{ generation }"
	puts m
		
	m = m.breed
	generation += 1
end
