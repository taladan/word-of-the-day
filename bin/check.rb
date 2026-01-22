#!/usr/bin/ruby
# /home/taladan/Documents/facebook/word/bin/check.rb
require 'bundler/setup'
require_relative "./generate-wod-image"

module Check
  # Match passed arguments against already posted words 
  def self.check_posted_words(args)
    args.each do |a|
      WordScraper.new(a)
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

  Check.check_posted_words(ARGV)
end
