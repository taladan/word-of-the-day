#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mini_magick'
require 'word_wrap'
require 'json'

def query_user 
  puts 'Please type or paste the word to use: ' 
  gets.chomp
end

user_word = ARGV[0] || query_user

text = `curl https://api.dictionaryapi.dev/api/v2/entries/en/#{user_word}`
json = JSON.parse(text)
word = json[0]['word']
word_type = json[0]['meanings'][0]['partOfSpeech']
word_definition = WordWrap.ww(json[0]['meanings'][0]['definitions'][0]['definition'], width=50)
filename = "#{word}.jpg"
archive_path = './posted/'


background_image_path = './assets/old-brown-paper-texture-image.jpg'
page_title = 'Word of the Day...'

image = MiniMagick::Image.open(background_image_path)
# word_pronunciation = json[0]["phonetic"].to_word

# Draw each element with text formatting

image.combine_options do |c| 
  # Title shadow
  c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
  c.style 'Bold'
  c.style 'Italic'
  c.fill '#03030350'
  c.pointsize 141
  c.draw "text 155,205 '#{page_title}'"

  # Title
  c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
  c.style 'Bold'
  c.style 'Italic'
  c.fill 'black'
  c.pointsize 141
  c.draw "text 150,200 '#{page_title}'"

  # Word dropshadow
  c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
  c.style 'Bold'
  c.fill '#05050580'
  c.pointsize 100
  c.draw "text 155,505 '#{word}'"

  # Word
  c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
  c.style 'Bold'
  c.fill 'black'
  c.pointsize 100
  c.draw "text 150,500 '#{word}'"

  # Word type
  c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
  c.pointsize 50
  c.draw "text 150,575 '(#{word_type})'"

  # Definition
  c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
  c.pointsize 55
  c.draw "text 150,750'#{word_definition}'"
end

image.write filename

puts "Image with overlaid text saved as: #{filename}"
