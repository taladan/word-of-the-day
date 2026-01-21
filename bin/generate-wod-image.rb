#!/usr/bin/env ruby
# frozen_string_literal: true


require_relative '../lib/chooser'
require_relative '../lib/wod_image_builder'
require_relative '../lib/data_handler'

require 'mini_magick'
require 'word_wrap'
require 'json'
require 'net/http'
require 'uri'

class WordScraper
  API_KEY = File.read('./data/secrets').strip
  def initialize(define_word)
    @json = retrieve_mw_json(define_word)

    if @json.empty? || !@json[0].is_a?(Hash)
      puts "No definitions found for #{define_word}"
      exit
    end

    @users_chosen = Chooser.new(define_word, get_definitions)
    ImageBuilder.new(word, usage, definition, example)
  end

  def word
    @users_chosen.word
  end

  def usage
    @users_chosen.usage
  end

  def definition
    @users_chosen.definition
  end

  def example
    @users_chosen.example
  end

  # Save chosen word to disk
  def save_word(word, usage, definition, example)
    packet = {word: "#{word}", usage: "#{usage}", definition: "#{definition}", example: "#{example}"} 
    @datahandler.write(packet)
  end

  private
  def retrieve_mw_json(word)
    url = "https://www.dictionaryapi.com/api/v3/references/collegiate/json/#{word}?key=#{API_KEY}"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      puts "API Error: #{response.code} #{response.message}"
      exit
    end

  rescue StandardError => e 
    puts "Connection Error: #{e.message}"
    exit
  end

  def get_definitions
    definitions = []

    @json.each do |entry|
      part_of_speech = entry['fl']

      if entry['def']
         entry['def'].each do |definition_section|
          definition_section['sseq']&.each do |sseq|
            sseq.each do |sense_wrapper|
              # Sense data is often in an array where the second element is the hash
              sense = sense_wrapper[1]
              next unless sense.is_a?(Hash) && sense['dt']

              # dt (defining text) is an array containing the definition and illustrations
              definition_text = ""
              example_text = nil

              sense['dt'].each do |dt_item|
                case dt_item[0]
                when "text"
                  definition_text = dt_item[1]
                when "vis"
                  if dt_item[1].is_a?(Array) && dt_item[1][0]
                    example_text = dt_item[1][0]['t']
                  end
                end
              end

              # Cleanup markup from Merriam Webster
              clean_def = definition_text.gsub(/\{.*?\}/, "").strip
              # Remove leading colon/space
              clean_def = clean_def.gsub(/^:\s*/, "")

              # only add to list if definition is not empty
              if clean_def.match?(/[a-zA-Z0-9]/)
                clean_ex = example_text&.gsub(/\{.*?\}/, "")&.strip
                definitions << [part_of_speech, clean_def, clean_ex]
              end
            end
          end
         end
      end
    end
    definitions
  end
end