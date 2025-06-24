# frozen_string_literal: true


# This object manages the mechanics of navigating making
# the choice of which daily events to keep and which to toss
class Chooser
  def initialize(word, items, generator_settings, maxitems=1)
    @word = word
    @settings = generator_settings
    @kept = []
    @limit = maxitems
    navigate_array(items)
  end

  # allows for circular navigation of event items  
  # limits selection to 3 unique events from given array
  def navigate_array(items)
    current_index = 0
    begin
      loop do
        system 'clear'
        break if @kept.length == @limit

        header

        if @kept.include?(items[current_index].sub(' ', ' - ')) 
          puts 'This definition has been chosen already'
        else 
          puts "Current Definition:\n\n#{items[current_index]}"
        end

        footer

        char = STDIN.getch

        if char == "\e" # Escape sequence detected
          char += STDIN.getch # read the '['
          char += STDIN.getch # read the direction 'A, B, C, or D'
        end

        case char
        when "\e[D"
          current_index = (current_index - 1) % items.size
        when "\e[B"
          current_index = (current_index - 1) % items.size
        when "\e[C"
          current_index = (current_index + 1) % items.size
        when "\e[A"
          current_index = (current_index + 1) % items.size
        when 'k'
          @kept << items[current_index].sub(' ', ' - ') unless @kept.include?(items[current_index].sub(' ', ' - '))
        when 'q'
          puts 'Quitting'
          sleep(1)
          system 'clear'
          exit
        when "\u0003"
          puts "\nExiting..."
          exit
        end
      end

    rescue Errno::EINTR
      puts "\nInterrupted."
    rescue StandardError => e
      puts "An error occured: #{e.message}"
    end
  end

  def choices
    @kept
  end

  private

  # header text
  def header
    puts "Word:\n"
    puts "\t#{@word}\n\n"
    puts "\n\nPress 'K' to keep a definition."
    puts "\n\n"
  end

  def footer
    puts "\n\n"
    puts 'Use left/right arrows to navigate (q to quit)'
  end

end
