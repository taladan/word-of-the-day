#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'shellwords'

PROJECT_ROOT = File.expand_path('..', __dir__) 
DATA_PATH    = File.join(PROJECT_ROOT, 'data')
ASSETS_PATH  = File.join(PROJECT_ROOT, 'assets')
QUEUE_PATH   = File.join(PROJECT_ROOT, 'post_queue') 
[DATA_PATH, ASSETS_PATH].each { |d| Dir.mkdir(d) unless Dir.exist?(d) }
SCHEDULER = "ssched"

require_relative File.join(PROJECT_ROOT, 'lib', 'chooser')
require_relative File.join(PROJECT_ROOT, 'lib', 'wod_image_builder')
require_relative File.join(PROJECT_ROOT, 'lib', 'data_handler')

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

    if @users_chosen.definition.nil?
      puts "No definition selected. Exiting."
      exit
    end

    # Controls opening, writing, and saving of word data to JSON database
    @datahandler = DataHandle.new

    save_word(word, usage, definition, example)

    # Build our image
    builder = ImageBuilder.new(word, usage, definition, example)
    @image_filename = builder.filename

    offer_to_schedule
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
    packet = {
      word: word, 
      usage: usage, 
      definition: definition, 
      example: example
  }
    @datahandler.write(packet)
  end

  private
  def offer_to_schedule
    puts "\n" + "-" * 40
    puts "Image generated successfully: #{@image_filename}"
    print "Would you like to schedule this post now? [Y/n]: "
    answer = STDIN.gets.chomp.downcase
  
    if answer == 'y' || answer == ''
      schedule_post
    else
      puts "Done. Image saved but not scheduled."
    end
  end

  def generate_alt_text
    text = "Word of the Day: #{word} (#{usage}). Definition: #{definition}."
    text += " Example: #{example}" if example && !example.empty?
    text
  end

  def schedule_post
    alt_text = generate_alt_text
    image_path = File.join(QUEUE_PATH, @image_filename)

    print "What date/time should this post? "
    post_date = STDIN.gets.chomp.downcase

    puts "\nPreparing to schedule..."
    puts "Alt Text generated: \"#{alt_text}\""

    safe_alt_text = Shellwords.escape(alt_text)
    safe_image_path = Shellwords.escape(image_path)
    safe_date = Shellwords.escape(post_date)

    command = "#{SCHEDULER} -i #{safe_image_path} -a #{safe_alt_text} -c Word -t #{safe_date}"

    puts "Handoff to scheduler script..."
    success = Bundler.with_unbundled_env do
      system(command)
    end

    if success
      puts "\n--- Scheduling Handoff Complete ---"
    else
      puts "\n---  Error during scheduling handoff ---"
      puts "\n---  Manual scheduling necessary     ---"
    end
  end

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


              # Clean tags
              clean_mw_text = ->(text) {
                return nil if text.nil?
                text.gsub(/\{(?:a_link|d_link|sx)\|([^}|]+)(?:\|[^}]*)?\}/, '\1')
                    .gsub(/\{.*?\}/, "") # Remove remaining non-content tags like {bc}
                    .strip
              }

              # Cleanup markup from Merriam Webster
              clean_def = clean_mw_text.call(definition_text)
              # Remove leading colon/space
              clean_def = clean_def.gsub(/^:\s*/, "")

              clean_ex = clean_mw_text.call(example_text)

              # only add to list if definition is not empty
              if clean_def.match?(/[a-zA-Z0-9]/)
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