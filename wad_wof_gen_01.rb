# Ruby code file - All your code should be located between the comments provided.

# Main class module
module WOF_Game
	# Input and output constants processed by subprocesses. MUST NOT change.
	GOES = 5

	class Game
		attr_reader :template, :wordtable, :input, :output, :turn, :turnsleft, :winner, :secretword, :played, :score, :resulta, :resultb, :guess
		attr_writer :template, :wordtable, :input, :output, :turn, :turnsleft, :winner, :secretword, :played, :score, :resulta, :resultb, :guess
		
		def initialize(input, output)
			@input = input
			@output = output
			@played = 0
			@score = 0
		end
		
		def getguess
			guess = @input.gets.chomp.upcase
		end
		
		def storeguess(guess)
			if guess != ""
				@resulta = @resulta.to_a.push "#{guess}"
			end
		end
		
		# Any code/methods aimed at passing the RSpect tests should be added below.
        
        def start
            @output.puts "Welcome to Hangman!"
            @output.puts "Created by: #{created_by} (#{student_id})"
            @output.puts "Starting game..."
            @output.puts "Enter 1 to run the game in the command-line window or 2 to run it in a web browser"
        end
        
        def created_by
            "Man Kit Liew"
        end
        
        def student_id
            51766803
        end
        
        def displaymenu
            clean_screen
            @output.puts "Menu: (1) Play | (2) New | (3) Analysis | (9) Exit"
        end
        
        def resetgame
            @wordtable = Array.new
            @secretword = ""
            @turn = 0
            @turnsleft = 0
            @resulta = Array.new
            @resultb = Array.new
            @winner = 0
            @guess = ""
            @template = "[]"
        end
        
        def readwordfile(name)
            words = Array.new
            IO.foreach(name) {|x| words.push(x.strip) }
            @wordtable = words
            return words.size
        end
        
        def gensecretword
            @wordtable.sample.upcase
        end
        
        def setsecretword(word)
            @secretword = word
        end
        
        def getsecretword
            @secretword
        end
        
        def createtemplate
            @template = ""
            @secretword.each_char do |char|
                @template += char == " " ? " " : " " "_"
            end
        end
        
        def incrementturn
            @turn += 1
        end
        
        def getturnsleft
            @turnsleft = GOES - @turn
        end
        
        def clean_screen
            system "clear" or system "cls"
        end
        
        def start_console_game
            menu_input
        end
        
        def menu_input
            displaymenu
            choice = @input.gets.chomp  
            
            case choice
            when "1"
                play
            when "2"
                File.delete("console_word.txt") if File.exists?("console_word.txt")
                resetgame
                get_word("console_word.txt")
                save_word("console_word.txt")
                @temp = nil
                clean_screen
                menu_input
            when "3"
                get_word("console_word.txt")
                show_analysis
            when "9"
                exit
            else
                menu_input
            end
        end
        
        def generate_game
            readwordfile("wordfile.txt")
            setsecretword(gensecretword)
            createtemplate
        end
        
        def play
            clean_screen
            get_word("console_word.txt")
            show_ui
            while @winner != 1 && @turnsleft != "0"
                get_word("console_word.txt")
                guess = getguess
                guess = guess[0] if guess.size > 1
                if guess == ""
                    menu_input
                else
                    guess.gsub!(/[^a-zA-Z]/, '')
                    found = false
                    added = false
                    if guess != "" && add_leter?(guess)
                        index = 0
                        @secretword.each_char do |x|
                            if x == guess
                                found = true
                                @template[index] = x
                                @resultb[index] = x
                            end
                            index += 1
                        end
                        added = true if storeguess (guess)              
                        incrementturn if !found
                        @turnsleft = increase_string(@turnsleft, -1) if !found
                        @winner = 1 if is_answer?
                    end
                    save_word("console_word.txt")
                    clean_screen
                    get_word("console_word.txt")
                    if guess == ""
                        show_ui_invalid
                    elsif found
                        show_ui_correct
                    elsif resulta.include?(guess) && added == false
                        show_ui_already
                    else
                        show_ui_wrong
                    end
                end
            end
            
            clean_screen
            if @winner == 1
                @wins = increase_string(@wins, 1)
                puts "Congratulations you won! The word was #{@secretword}\n\n"
            else
                @loses = increase_string(@loses, 1)
                puts "You lost! The word was: #{@secretword}\n\n"
            end
            @games = increase_string(@games, 1)
            save_stats("console_stats.txt")
            File.delete("console_word.txt") if File.exists?("console_word.txt")
        end
        
        def ui_template
            " Press enter to get back to menu\nWORD: [#{@template.strip!}] TURNS LEFT: #{turnsleft.strip!} | USED LETTERS: #{@resulta}"
        end
        
        def show_ui
            puts "Guess missing character." << ui_template
        end
        
        def show_ui_invalid
            puts "This character is invalid, try again!" << ui_template
        end
        
        def show_ui_wrong
            puts "This character don't appear in our word, try again." << ui_template
        end
        
        def show_ui_already
            puts "You already used this character, try other character." << ui_template
        end
        
        def show_ui_correct
            puts "Nice, this character appears in our word, guess next one." << ui_template
        end
        
        def add_leter?(letter)
            return false if letter.match (/\s/)  || resulta.include?(letter)
            return true
        end
        
        def is_answer?
            index = 0
            @secretword.each_char do |x|
                return false if x != template[index] && x != ""
                index += 1
            end
            return true
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
                @games = "0"; @wins = "0"; @loses = "0"
            end
        end
        
        def save_stats(filename)
            @games.strip!; @wins.strip!; @loses.strip!
            IO.write(filename, "#{@games}\n#{@wins}\n#{@loses}")
        end
        
        def get_word(filename)
            if File.exists?(filename) 
                line_number = 1
                @used_letters = ""
                @resulta = Array.new
                File.foreach(filename) do |x|
                    @secretword = x if line_number == 1
                    @template = x if line_number == 2
                    @turnsleft = x if line_number == 3
                    @temp = x if line_number == 4
                    line_number += 1
                end
                @temp != nil ? @temp.each_char {|x| @resulta.push(x) if x != " "} : @resulta.clear
            else
                @words = Array.new
                IO.foreach("wordfile.txt") {|x| @words.push (x.strip)}
                @secretword = @words.sample.upcase
                @template = ""
                @secretword.each_char {|x| @template += x == " " ? " " : "_"}
                @turnsleft = "5"
                @resulta = Array.new
                IO.write(filename, "#{@secretword}\n#{@template}\n#{@turnsleft}\n")
            end
        end
        
        def save_word(filename)
            @secretword.strip!; 
            @template.strip!; 
            # @resulta.strip!
            IO.write(filename, "#{@secretword}\n#{@template}\n#{@turnsleft.to_s.strip}\n#{@resulta.join(' ').strip}")
        end
        
        def increase_string(number, by)
            number = number.strip.to_i
            number += by
            number.to_s
        end
        
        def show_analysis
            clean_screen
            puts "GAME ANALYSIS:\n\n GAME STATISTICS: \n | Total Games: #{@games} | Total Wins #{@wins} | Total Loses #{@loses} \n | Win Rate #{((@wins.strip.to_i * 100.0) / (@games.strip.to_i * 100.0) * 100).round(2)} % \n\n"
            puts " WORD STATISTICS: \n | Current Word: #{@template} | Used Letters: #{@resulta} \n | Turns Left #{@turnsleft}\n\n"
            puts "Press any key to get back to menu"
            @input.gets.chomp
            menu_input
        end
		
		# Any code/methods aimed at passing the RSpect tests should be added above.

	end
end


