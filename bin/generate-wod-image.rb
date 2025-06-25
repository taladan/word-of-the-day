#!/usr/bin/env ruby
# frozen_string_literal: true


require_relative "../lib/chooser"
require_relative "../lib/wod_image_builder"

require 'mini_magick'
require 'word_wrap'
require 'json'

class WordGen
  def initialize(define_word)
    @json = clean_up_json(retrieve_json(define_word))
    @users_chosen = Chooser.new(@json[0]['word'], get_definitions)
    ImageBuilder.new(@users_chosen.word, @users_chosen.usage, @users_chosen.definition)
  end


  private
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
  
  # parse definitions out of JSON data including the part of speech for each definition
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
end