#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mini_magick'
require 'word_wrap'
class ImageBuilder
  # Standard margin/font constants
  MARGIN_X = 150
  FONT_SIZE_DEFINITION=96
  FONT_SIZE_WORD = 140

  def initialize(word, usage, definition, example)
    @word = word
    @usage = usage
    @definition = definition
    @example = example
    @background_images = './assets'
    @page_title = 'Word of the Day...'

    # Open image and capture width for calculations
    @image = MiniMagick::Image.open(get_background_image)
    @image_width = @image.width

    seconds_since_midnight = Time.now.to_i % 86400
    @filename = "#{@word}_#{seconds_since_midnight}.jpeg"

    draw_image
    output_image
    puts "#{@filename} written"
  end

  private 

  # Calculate safe wrap width
  def calculate_wrap_width(pointsize)
    available_pixels = @image_width = (MARGIN_X * 2)

    # conservative average width/height ratio
    avg_char_width = pointsize * 0.080

    # Number of characters that fit
    (available_pixels / avg_char_width).to_i
  end

  # Wrap definition dynamically
  def parse_definition
    wrap_limit = calculate_wrap_width(FONT_SIZE_DEFINITION)
    WordWrap.ww(@definition.gsub("'", "\\\\'").gsub("\n", '\n'), wrap_limit)
  end

  # Wrap example dynamically
  def parse_example
    wrap_limit = calculate_wrap_width(FONT_SIZE_DEFINITION)
    WordWrap.ww(@example.gsub("'", "\\\\'").gsub("\n", '\n'), wrap_limit)
  end

  def get_background_image
    Dir.glob("#{@background_images}/*.jpeg").sample
  end

  def update_y(current_y, pointsize, padding=1.2)
    current_y += pointsize * padding
  end

  def draw_image
    current_y = 200 # Vert start position

    @image.combine_options do |c|
      # -- Page Title --
      font_title = '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
      pointsize_title = 181
      title_text = @page_title

      # title shadow
      c.font font_title
      c.style 'Bold'
      c.style 'Italic'
      c.fill '#030303'
      c.pointsize pointsize_title
      c.draw "text #{MARGIN_X},#{current_y} '#{title_text}'"

      current_y = update_y(current_y, pointsize_title)
      current_y += 50

      # -- Word --
      font_word = '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
      
      # Dynamic scaling for long words
      # If word is too long, shrink font size to fit margins
      current_word_font_size = FONT_SIZE_WORD
      safe_width_chars = calculate_wrap_width(current_word_font_size)
      
      while @word.length > safe_width_chars && current_word_font_size > 50
        current_word_font_size -= 5
        safe_width_chars = calculate_wrap_width(current_word_font_size)
      end

      word_text = @word

      # Word dropshadow
      c.font font_word
      c.style 'Bold'
      c.fill '#05050580'
      c.pointsize current_word_font_size
      c.draw "text #{MARGIN_X + 5},#{current_y + 5} '#{word_text}'"

      # Word
      c.font font_word
      c.style 'Bold'
      c.fill 'black'
      c.pointsize current_word_font_size
      c.draw "text #{MARGIN_X},#{current_y} '#{word_text}'"

      current_y = update_y(current_y, current_word_font_size)

      # -- Grammatical Usage --
      font_usage = '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
      pointsize_usage = 90
      usage_text = "#{@usage}"

      c.font font_usage
      c.style 'Italic'
      c.fill 'black'
      c.pointsize pointsize_usage
      c.draw "text #{MARGIN_X},#{current_y} '(#{usage_text})'"
      
      current_y = update_y(current_y, pointsize_usage)
      current_y += 50 

      # -- Definition --
      font_definition = '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
      # Use constant for consistency
      pointsize_definition = FONT_SIZE_DEFINITION 
      parsed_definition_text = parse_definition

      c.font font_definition
      c.pointsize pointsize_definition
      c.draw "text #{MARGIN_X},#{current_y} '#{parsed_definition_text}'"
      
      # Calculate height for multiline definition
      definition_lines = parsed_definition_text.split("\n").length
      current_y += definition_lines * (pointsize_definition * 1.2)
      current_y += 100 

      # -- Example --
      if @example
        font_example_title = '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
        pointsize_example_title = 115
        example_title_text = 'Example:'

        c.font font_example_title
        c.style 'Bold'
        c.style 'Italic'
        c.fill 'black'
        c.pointsize pointsize_example_title
        c.draw "text #{MARGIN_X},#{current_y} '#{example_title_text}'"

        current_y += 150 

        font_example_text = '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
        pointsize_example_text = FONT_SIZE_DEFINITION
        parsed_example_text = parse_example

        c.font font_example_text
        c.pointsize pointsize_example_text
        c.draw "text #{MARGIN_X},#{current_y} '#{parsed_example_text}'"
      end
    end
  end

  def output_image
    @image.write @filename
  end
end


# THIS IS ALL DEPRECATED CODE.
# class OldImageBuilder
#   def initialize(word, usage, definition, example)
#     @word = word
#     @usage = usage
#     @definition = definition
#     @example = example
#     @background_images = './assets/'
#     @page_title = 'Word of the Day...'
#     @image = MiniMagick::Image.open(get_background_image)
#     seconds_since_midnight = Time.now.to_i % 86400 
#     @filename = "#{@word}_#{seconds_since_midnight}.jpeg"
#     draw_image
#     output_image
#     puts "#{@filename} written"
#   end
  
#   private

#   # wrap definition at appropriate width for image
#   def parse_definition
#     WordWrap.ww(@definition.gsub("'", "\\\\'").gsub("\n", '\n'), width=40)
#   end

#   def parse_example
#     WordWrap.ww(@example.gsub("'", "\\\\'").gsub("\n", '\n'), width=40)
#   end

#   def get_background_image
#     Dir.glob("#{@background_images}*.jpeg").sample
#   end


#   # update Y expects current_y, pointsize, and padding
#   def update_y(current_y, pointsize, padding=1.2)
#     current_y += pointsize * padding
#   end

#   # Draw each element with text formatting
#   def draw_image
#     current_y = 200 # Vertical Starting position

#     @image.combine_options do |c| 
#       # -- Page Title --
#       font_title = '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
#       pointsize_title = 181
#       title_text = @page_title

#       # Title shadow
#       c.font font_title
#       c.style 'Bold'
#       c.style 'Italic'
#       c.fill '#03030350'
#       c.pointsize pointsize_title
#       c.draw "text 155,#{current_y + 5} '#{title_text}'" # Shadow Offset

#       # Title
#       c.font font_title
#       c.style 'Bold'
#       c.style 'Italic'
#       c.fill 'black'
#       c.pointsize pointsize_title
#       c.draw "text 150,#{current_y} '#{title_text}'"

#       current_y = update_y(current_y, pointsize_title) # update current y
#       current_y += 50 # plus additional padding

#       # -- Word -- 
#       font_word = '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
#       pointsize_word = 140
#       word_text = @word

#       # Word dropshadow
#       c.font font_word
#       c.style 'Bold'
#       c.fill '#05050580'
#       c.pointsize pointsize_word
#       c.draw "text 155,#{current_y + 5} '#{word_text}'"

#       # Word
#       c.font font_word
#       c.style 'Bold'
#       c.fill 'black'
#       c.pointsize pointsize_word
#       c.draw "text 150,#{current_y} '#{word_text}'"

#       current_y = update_y(current_y, pointsize_word) # update current Y
#       # current_y += 5 # plus additional padding

#       # -- Grammatical Usage --
#       font_usage = '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
#       pointsize_usage = 90
#       usage_text = "#{@usage}"

#       c.font font_usage
#       c.style 'Italic'
#       c.fill 'black'
#       c.pointsize pointsize_usage
#       c.draw "text 150,#{current_y} '(#{usage_text})'"
      
#       current_y = update_y(current_y, pointsize_usage)
#       current_y += 50 # pad before definition

#       # -- Definition --
#       font_definition = '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
#       pointsize_definition = 95
#       parsed_definition_text = parse_definition # already wordwrapped

#       c.font font_definition
#       c.pointsize pointsize_definition
#       c.draw "text 150,#{current_y} '#{parsed_definition_text}'"
      
#       # Calculate height for multiline definition
#       definition_lines = parsed_definition_text.split("\n").length
#       # current_y = update_y(current_y, pointsize_definition)
#       current_y += definition_lines * (pointsize_definition * 1.2)
#       current_y += 100 # add significant padding

#       # only try to put the example on the image if the example exists
#       if @example
#         font_example_title = '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
#         pointsize_example_title = 115
#         example_title_text = 'Example:'

#         # Example Section Title
#         c.font font_example_title
#         c.style 'Bold'
#         c.style 'Italic'
#         c.fill 'black'
#         c.pointsize pointsize_example_title
#         c.draw "text 150,#{current_y} '#{example_title_text}"

#         # current_y += update_y(current_y, pointsize_example_title) # update y
#         current_y += 150 # add padding

#         # Example text
#         font_example_text = '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
#         pointsize_example_text = 95
#         parsed_example_text = parse_example

#         c.font font_example_text
#         c.pointsize pointsize_example_text
#         c.draw "text 150,#{current_y} '#{parsed_example_text}'"
#       end
#     end
#   end

#   def output_image
#     @image.write @filename
#   end
# end