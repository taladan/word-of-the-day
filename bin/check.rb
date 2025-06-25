#!/usr/bin/ruby
# /home/taladan/Documents/facebook/word/bin/check.rb
require 'bundler/setup'
require_relative "./generate-wod-image"

module Check
# Match passed arguments against already posted words 
  def self.check_posted_words(args, posted_words)
    args.each do |a|
      if posted_words.include?(a)
        input = ''
        until ['Y', 'y', 'n', 'N'].include?(input) 
          system 'clear'
          puts "#{a} has already been posted. Proceed (Y/N)?"
          input = STDIN.gets.chomp
        end
        if ['Y','y'].include?(input) 
          WordScraper.new(a)
        else
          exit
        end
      else
        WordScraper.new(a)
      end
    end
  end
end

# run this if the file is run manually
if __FILE__ == $0
  # This relies on a bash script with hard-coded values to search for.
  # modify it for your own purposes.
  #
  # the shell script as of current writing is:
  # basename -a /home/taladan/Documents/facebook/word/posted/*.jpg | sed 's/\.jpg$//'

  Check.check_posted_words(ARGV, `list_posted_words.sh`.split)
end
