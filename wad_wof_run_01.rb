# Ruby code file - All your code should be located between the comments provided.

# Add any additional gems and global variables here
require 'sinatra'		

# The file where you are to write code to pass the tests must be present in the same folder.
# See http://rspec.codeschool.com/levels/1 for help about RSpec
require "#{File.dirname(__FILE__)}/wad_wof_gen_01"

# Main program
module WOF_Game
	@input = STDIN
	@output = STDOUT
	g = Game.new(@input, @output)
	playing = true
	input = ""
	menu = ""
	guess = ""
	secret = ""
	filename = "wordfile.txt"
	turn = 0
	win = 0
	game = ""
	words = 0

	@output.puts 'Enter "1" runs game in command-line window or "2" runs it in web browser.'
	game = @input.gets.chomp
	if game == "1"
		@output.puts "Command line game"
	elsif game == "2"
		@output.puts "Web-based game"
	else
		@output.puts "Invalid input! No game selected."
		exit
	end
		
	if game == "1"
		
	# Any code added to command line game should be added below.
    
    puts "-------------"
    g.resetgame
    g.get_stats("console_stats.txt")
    #g.generate_game
    g.get_word("console_word.txt")
    g.start_console_game

		
	# Any code added to command line game should be added above.
	
		exit	# Does not allow command-line game to run code below relating to web-based version
	end
end
# End modules

# Sinatra routes

	# Any code added to web-based game should be added below.

    helpers do
        def add_leter?(letter)
            return false if letter.match (/\s/) || @used_letters.include?(letter)
            return true
        end
        
        def is_answer?
            index = 0
            @secret_word.each_char do |x|
                return false if x != @hidden_word[index] && x != " "
                index += 1
            end
            return true
        end
        
        def get_word(filename)
            if File.exists?(filename)
                line_nmber = 1
                @used_letters = ""
                File.foreach(filename) do |x|
                    @secret_word = x if line_number == 1
                    @hidden_word = x if line_number == 2
                    @turns_left = x if line_number == 3
                    @used_letters = x if line_number == 4
                    line_number += 1
                end
            else
                @words = Array.new
                IO.foreach("wordfile.txt") {|x| @words.push(x.strip)} 
                @secret_word = @words.sample.upcase
                @hidden_word = ""
                @secret_word.each_char {|x| @hidden_word += x == " " ? " " : "_"} 
                @turns_left = "5"
                @used_letters = " "
                IO.write(filename, "#{@secret_word}\n#{@hidden_word}\n#{@turns_left}\n")
            end
        end
        
        def save_word(filename)
            @secret_word.strip!; @hidden_word.strip!; @turns_left.strip!; @used_letters.strip!;
            IO.write(filename, "#{@secret_word}\n#{@hidden_word}\n#{@turns_left}\n#{@used_letters}")
        end
        
        def get_stats(filename)
            if File.exists?(filename)
                line_number = 1
                File.foreach(filename) do |x|
                    @games = x if line_number == 1
                    @wins = x if line_number == 2
                    @loses = x if line_number == 3
                    line_number += 1
                end
            else
                IO.write(filename, "0\n0\n0")
                @games = "0"; @wins = "0"; @loses= "0"
            end
        end
        
        def save_stats(filename)
            @games.strip!; @wins.strip!; @loses.strip!
            IO.write(filename, "#{@games}\n#{@wins}\n#{@loses}")
        end
        
        def increase_string(number, by)
            number = number.strip.to_i
            number += by
            number.to_s
        end
        
        def get_words_count
            @words = Array.new
            IO.foreach("wordfile.txt") {|x| @words.push (x.strip)}
            return @words.size
        end
    end

    get '/' do
        get_stats("web_stats.txt")
        get_word("web_word.txt")
        
        redirect to('/won/') if is_answer?
        redirect to ('/lost/') if @turns_left.strip.to_i <= 0
        
        erb :index
    end

    get 'add/:char' do
        get_stats("web_stats.txt")
        get_word("web_word.txt")
        
        char = params["char"]
        redirect to ('/') unless char
        char = char[0] if char.size > 1
        char.gsub!(/[^a-zA-Z]/, '')
        char.upcase!
        
        if char != "" && add_leter?(char)
            index = 0
            found = false
            @secret_word.each_char do |x|
                @hidden_word[index] = x if x == char
                found = true if x == char
                index += 1
            end
            @used_letters << char << " "
            @turns_left = increase_string(@turns_left, -1) if !found
            @wins = increase_string(@wins, 1) if is_answer?
            @games = increase_string(@games, 1) if is answer?
            save_word("web_word.txt")
            save_stats("web_stats.txt")
        end
        redirect to('/')
    end

    get '/won/' do
        get_stats("web_stats.txt")
        get_word("web_word.txt")
        redirect to('/') unless is_answer?
        erb :won
    end

    get '/lost/' do
        get_stats("web_stats.txt")
        get_word("web_word.txt")
        redirect to('/') unless @turns_left.strip.to_i <= 0
        erb :lost
    end

    get '/reset/' do
        get_stats("web_stats.txt")
        get_word("web_word.txt")
        
        @loses = increase_string(@loses, 1) unless is_answer?
        @games = increase_string(@games, 1) unless is_answer?
        save_stats("web_stats.txt")
        
        File.delete("web_word.txt") if File.exists? ("web_word.txt")
        redirect to ('/')
    end

    not_found do
        redirect to ('/')
    end              

	# Any code added to web-based game should be added above.

# End program