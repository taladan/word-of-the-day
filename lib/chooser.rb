# frozen_string_literal: true

require 'io/console'
require 'colorize'

# This object manages the mechanics of navigating making
# the choice of which daily events to keep and which to toss
class Chooser
  def initialize(word, items, maxitems=1)
    @word = word
    @kept = []
    @limit = maxitems
    @data_handler = DataHandle.new
    navigate_array(items)
  end

  # return the chosen word
  def word
    return @word
  end

  # return the usage of the chosen definition
  def usage
    return @kept[0]
  end

  # return the chosen definition
  def definition
    return @kept[1]
  end

  # return the example
  def example
    return @kept[2]
  end

  # allows for circular navigation of event items  
  def navigate_array(items)
    current_index = 0
    begin
      loop do
        system 'clear'
        break if @kept.length == @limit

        # Determin if this def is in JSON
        is_used = @data_handler.definition_used?(@word, items[current_index][0], items[current_index][1])

        # set color based on usage status
        display_color = is_used ? :light_red : :white

        header(items[current_index], display_color)

        puts "\n\nCurrent Definition:".colorize(display_color).bold
        puts "\n\n\t#{items[current_index][1]}".colorize(display_color)

        puts "\n\nExample:".colorize(display_color).bold
        puts "\n\n\t#{items[current_index][2]}".colorize(display_color)

        footer(display_color)

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
          @kept = items[current_index] unless @kept.include?(items[current_index])
          puts 'Finalizing choice'
          sleep(1)
          system 'clear'
          break
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
    return @kept
  end

  private

  # header text
  def header(items, color)
    puts "Word:".colorize(color).bold
    puts "\n\t#{@word}\n\n".colorize(color)
    puts "Usage:".bold.colorize(color).bold
    puts "\n\t#{items[0]}".colorize(color)
  end

  def footer
    keep_key = "K".bold
    quit_key = "Q".bold
    puts "\n\n\n\n".colorize(color)
    puts "\t\tUse left/right arrows to navigate (#{quit_key} to quit)".colorize(color)
    puts "\n\n".colorize(color)
    puts "\t\tPress #{keep_key} to keep a definition.".colorize(color)
    puts "\n\n"
  end

end
