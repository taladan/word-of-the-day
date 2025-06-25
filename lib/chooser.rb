# frozen_string_literal: true

require 'io/console'

# This object manages the mechanics of navigating making
# the choice of which daily events to keep and which to toss
class Chooser
  def initialize(word, items, maxitems=1)
    @word = word
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

        header(items[current_index])

        puts "Current Definition:\n\n#{items[current_index][1]}"

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
          @kept << items[current_index] unless @kept.include?(items[current_index])
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
  def header(items)
    puts "Word:\n"
    puts "\t#{@word}\n\n"
    puts "Usage:\n"
    puts "\t#{items[0]}"
    puts "\n\nPress 'K' to keep a definition."
    puts "\n\n"
  end

  def footer
    puts "\n\n"
    puts 'Use left/right arrows to navigate (q to quit)'
  end

end
