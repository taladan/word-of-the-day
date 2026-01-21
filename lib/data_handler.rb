#!/usr/bin/ruby
# /home/taladan/Documents/facebook/word/bin/data_handler.rb


# Handles data retrieval and storage of JSON data file
class DataHandle 
  def initialize
  end

  # TBD file search method
  def search(word)
    # File should be read into memory before parsing
    
    # File should be checked to see if it matches user requested Word
    file.readlines
    
    # If match IS found before EOF: 
    #   Close file if match is found
    #   Return match found status to program
    
    # If match IS NOT found before EOF:
    #   Close file
    #   Return "no match found" status to program

  # word retrieval method
    # search data file for word
    # if word exists, return record
    # if word does not exist, return no match found

  # word storage method
    # search data file for word
    # if word exists, update file with definitions and usage info for additional post
    # if word doesn't exist, store new word/usage/definition data to file
    # save file to disk
  end
  
  # Write packet of json containing word and definition to file
  def write(packet)
    words = read_data_file
    word = packet[:word]
    usage = packet[:usage]
    definition = packet[:definition]
    example = packet[:example]
    index = words[word] ? words[word].count + 1 : 1
    words[word] = {index => {usage: "#{usage}", definition: "#{definition}", example: "#{example}"}}

    # We want to track the following data:
    #   Word
    #   Usage
    #   Definition
    #   [Example (optional)]
    # 
    # File should be stored on disc in the data/ directory.
    # 
    # The file should be structured so that each word is unique - no repeats of the word itself.
    # Each unique word can have multiple Entries.  
    # Each Entry consists of a Usage and Definition.
    # Each entry should be unique to itself (no matching combination of usage & definition). (hash?)

    # This is an example entry into the JSON file for the word 'Ball', assuming it has been posted 6 times with 6 different usage/definition pairs 
    
      # {
      #   "ball": {
      #     "1": [
      #       "noun",
      #       "A solid or hollow sphere, or roughly spherical mass.",
      #       "a ball of spittle; a fecal ball"],
      #     "2": [
      #       "noun",
      #       "A round or ellipsoidal object.",
      #       []
      #     ],
      #     "3": [
      #       "noun",
      #       "(mildly, usually in the plural) A testicle.",
      #       []
      #     ],
      #     "4": [
      #       "noun",
      #       "A leather-covered custion, fastened to a handle called a ballstock; formerly used by printers for inking the form, then superseded by the roller",
      #       []
      #     ],
      #     "5": [
      #       "noun",
      #       "A large pill, a form in which medicine was given to horses; a bolus.",
      #       []
      #     ],
      #     "6": [
      #       "verb",
      #       "To form or wind into a ball.",
      #       "to ball cotton"]}
      # }
    #
    # Given this structure, we should be expecting data within our program to follow the format:
    #
    # entry = {"ball" => {"1" => ["noun", "A solid or hollow sphere, or roughly spherical mass."', ["a ball spittle; a fecal ball"]']}}
  end

  private

  # Not sure if any of this is going to be necessary...probably not.  Feels kludgy.
  def full_path_to_data_file
    current_path = Dir.pwd + "/"
    data_directory = "data/"
    filename = "posted_words.json"

    "#{current_path}#{data_directory}#{filename}"
  end

  # Open file for reading
  def read_data_file
    File.zero?(full_path_to_data_file) ? {} : JSON.load_file(full_path_to_data_file)
  end
end