#!/usr/bin/env ruby
# frozen_string_literal: true


require_relative "../lib/chooser"

require 'mini_magick'
require 'word_wrap'
require 'json'

class WordGen
  def initialize(define_word)
    @json = clean_up_json(retrieve_json(define_word))
    @users_chosen = Chooser.new(@json[0]['word'], get_definitions)
  end

  # grab json entry from api.dictionary.dev
  def retrieve_json(word)
    `curl https://api.dictionaryapi.dev/api/v2/entries/en/#{word}`
  end

  # clean up json data - api.dictionary.dev sends hash rocket formats for JSON for some reason
  def clean_up_json(data)
    safe_json = data.gsub(/\"=>/, '":')

    begin 
      output = JSON.parse(safe_json)
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e.message}"
      puts "Problematic string (first 200 chars): #{safe_json[0..199]}..."
      exit
    end
    output
  end


  def get_definitions
    # Split definitions out of JSON data
    definitions = []
    @json.each do |entry|
      # Iterate through 'meanings' array for the current entry if it exists
      if entry['meanings']
        entry['meanings'].each do |meaning|
          part_of_speech = meaning['partOfSpeech']

          # Check for definitions
          if meaning['definitions']
            meaning['definitions'].each do |definition_hash|
              definition = definition_hash['definition']
              # pack part and definition into array
              if part_of_speech && definition
                definitions << [part_of_speech, definition]
              end
            end
          end
        end
      end
    end
    definitions
  end

  #######
  #old code below
  #######


  # word_definition = WordWrap.ww(@json[0]['meanings'][0]['definitions'][0]['definition'], width=50)
  # filename = "#{word}.jpg"
  # archive_path = './posted/'

  # background_image_path = './assets/old-brown-paper-texture-image.jpg'
  # page_title = 'Word of the Day...'

  # image = MiniMagick::Image.open(background_image_path)
  # word_pronunciation = json[0]["phonetic"].to_word

  # Draw each element with text formatting

  # image.combine_options do |c| 
  #   # Title shadow
  #   c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
  #   c.style 'Bold'
  #   c.style 'Italic'
  #   c.fill '#03030350'
  #   c.pointsize 141
  #   c.draw "text 155,205 '#{page_title}'"

  #   # Title
  #   c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
  #   c.style 'Bold'
  #   c.style 'Italic'
  #   c.fill 'black'
  #   c.pointsize 141
  #   c.draw "text 150,200 '#{page_title}'"

  #   # Word dropshadow
  #   c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
  #   c.style 'Bold'
  #   c.fill '#05050580'
  #   c.pointsize 100
  #   c.draw "text 155,505 '#{word}'"

  #   # Word
  #   c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
  #   c.style 'Bold'
  #   c.fill 'black'
  #   c.pointsize 100
  #   c.draw "text 150,500 '#{word}'"

  #   # Word type
  #   c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
  #   c.pointsize 50
  #   c.draw "text 150,575 '(#{word_type})'"

  #   # Definition
  #   c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
  #   c.pointsize 55
  #   c.draw "text 150,750'#{word_definition}'"
  # end

  # image.write filename

  # puts "Image with overlaid text saved as: #{filename}"
end