class Player

	def initialize(name)
		@name = name
		@turns = 12
	end

	def name
		@name
	end

	def play(secret_code)
		@turns.downto(1) do |i|
			puts "-" * 82
			puts "Please select four (4) colors: #{Game.colors}."
			puts i > 1 ? "To enter your guess list all four (4) of your color choices. You have #{i} turns remaining." : "To enter your guess type all four (4) of your color choices. Warning: It's your final turn!"
			guess = gets.chomp.split(/\W+/)
				if guess.size == 4
				Game.validate(guess, secret_code)
			else
				puts "Enter four (4) colors!"
			end
				if guess == secret_code
				puts "Congratulations, you guessed correctly!"
				exit(0)
			elsif i == 1
				puts "Aww, too bad. Better luck next time! The secret code was #{secret_code}."
				exit(0)
			else
				puts "That was a good guess but it was not correct. Please try again!"
			end
		end
	end   
end

class Computer < Player

	def initialize
		@name = 'Computer'
		@turns = 12
	end

	def play(secret_code)
		colors = Game.colors[0..-1]
		res = []
		mutation = nil
		guess = [colors.shuffle!.pop] * 4 
			@turns.downto(1) do |i|
			puts i > 1 ? "You have #{i} turns remaining and the computer's guess is #{guess}" : "You have #{i} turns remaning and the computer's guess is #{guess}"
			black, white = Game.validate(guess, secret_code)
				if guess == secret_code
				puts "The computer won! Better luck next time!"
				exit(0)
			elsif i == 1
				puts "Congratulations, you won!!"
				exit(0)
			elsif mutation
				guess = mutation.shuffle!.pop      
			elsif res.size == 4
				mutation = toss(res)
				guess = mutation.shuffle!.pop
			elsif black > 0
				res << [guess[0]] * black unless res.size == 4
				res.flatten!
				guess = (res.size == 4) ? res : [colors.shuffle!.pop] * 4
			else
				guess = [colors.shuffle!.pop] * 4
			end
		end
	end 

	def toss(res)
		mutation = res.permutation.to_a.uniq
	end 

end

class Game

	@@colors = ['red', 'orange', 'yellow', 'green', 'blue', 'purple']
	def self.colors
		@@colors
	end

	def self.validate(guess, secret_code)
		black = 0
		white = 0
		counted = []
			guess.each_with_index do |v, i|
			secret_code.each_with_index do |v_s, i_s|
				if v == v_s && i == i_s
					black += 1
					counted << i_s     
				elsif v == v_s && i != i_s 
					next if guess[i_s] == secret_code[i_s] || guess[i] == secret_code[i] || guess.index(v_s) < i && (counted.include? i_s)
					white += 1
					counted << i_s
				break
				end
			end
		end
			puts "-" * 21 
			puts "black: #{black} | white: #{white} |"
			puts "-" * 21
			[black, white]
		end

		def initialize(player)
			@player = player
			@computer = Computer.new
		end

		def start
			loop do
			puts %q(
				----------------------
				Choose a game:
					1. Create the code
					2. Guess the code
				----------------------
			)            
			destiny = gets.chomp.scan(/\d/)
				if destiny[0].to_i == 1
				create
			elsif destiny[0].to_i == 2        
				guess
			else
				puts "Invalid color choice. Try again."
			end
		end

		rescue Interrupt
			puts "Good luck and enjoy the game!"
		end

		def guess
			secret_code = []
				until secret_code.size == 4
			secret_code << @@colors.sample
		end

	@player.play(secret_code) 

	end

	def create
		puts "Create a secret code by selecting a sequence of four (4) colors."
		puts "Make sure your color slections are included in the #{@@colors} list!"
		secret_code = gets.chomp.split(/\W+/)
		if secret_code.size != 4
			puts "Your secret code should consist of four (4) colors."
		elsif secret_code.all? { |i| @@colors.include? i }
			@computer.play(secret_code)
		else
			puts "Please select four (4) colors from the colors #{@@colors} list."
		end
	end  

end

me = Player.new("Melony")
game = Game.new(me)
game.start
