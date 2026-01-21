#!/usr/bin/ruby
# /home/taladan/Documents/facebook/word/bin/data_handler.rb

require 'json'

# Handles data retrieval and storage of JSON data file
class DataHandle
  def initialize
    @file_path = File.join(Dir.pwd, 'data', 'posted_words.json')
    ensure_data_file_exists
  end
  
  # Write packet of json containing word and definition to file
  def write(packet)
    data = read_data_file
    word = packet[:word]

    # initialize word entry if non existant
    data[word] ||= {}

    # Unique index for this word
    index = (data[word].keys.map(&:to_i).max || 0) + 1

    # Store entry as array: [usage, definition, example]
    data[word][index.to_s] = {
      usage: packet[:usage],
      defintion: packet[:definition],
      example: packet[:example]
    }

    save_to_disk(data)
  end

  private

  def ensure_data_file_exists
    Dir.mkdir('data') unless Dir.exist?('data')
    unless File.exist?(@file_path)
      File.write(@file_path, JSON.generate({}))
    end
  end

  # Open file for reading
  def read_data_file
    return {} if File.zero?(@file_path)
    JSON.parse(File.read(@file_path))
  rescue JSON::ParserError
    {}
  end

  def save_to_disk(data)
    File.open(@file_path, 'w') do |f|
      f.write(JSON.pretty_generate(data))
    end
  end
end