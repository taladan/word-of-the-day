#!/usr/bin/env ruby
# frozen_string_literal: true


class ImageBuilder
  def initialize(word, usage, definition, example)
    @word = word
    @usage = usage
    @definition = definition
    @example = example
    @background_images = './assets/'
    @page_title = 'Word of the Day...'
    @image = MiniMagick::Image.open(get_background_image)
    seconds_since_midnight = Time.now.to_i % 86400 
    @filename = "#{@word}_#{seconds_since_midnight}.jpeg"
    draw_image
    output_image
    puts "#{@filename} written"
  end
  
  private

  # wrap definition at appropriate width for image
  def parse_definition
    WordWrap.ww(@definition.gsub("'", "\\\\'").gsub("\n", '\n'), width=40)
  end

  def parse_example
    WordWrap.ww(@example.gsub("'", "\\\\'").gsub("\n", '\n'), width=40)
  end

  def get_background_image
    Dir.glob("#{@background_images}*.jpeg").sample
  end
  # Draw each element with text formatting
  def draw_image
    @image.combine_options do |c| 
      # Title shadow
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
      c.style 'Bold'
      c.style 'Italic'
      c.fill '#03030350'
      c.pointsize 181
      c.draw "text 155,205 '#{@page_title}'"

      # Title
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
      c.style 'Bold'
      c.style 'Italic'
      c.fill 'black'
      c.pointsize 181
      c.draw "text 150,200 '#{@page_title}'"

      # Word dropshadow
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
      c.style 'Bold'
      c.fill '#05050580'
      c.pointsize 140
      c.draw "text 155,450 '#{@word}'"

      # Word
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
      c.style 'Bold'
      c.fill 'black'
      c.pointsize 140
      c.draw "text 150,452 '#{@word}'"

      # Grammatical Usage
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
      c.pointsize 90
      c.draw "text 150,575 '(#{@usage})'"
      
      # Definition
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
      c.pointsize 95
      c.draw "text 150,750'#{parse_definition}'"

      # only try to put the example on the image if the example exists
      if @example
        # Example Section Title
        c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
        c.style 'Bold'
        c.style 'Italic'
        c.fill 'black'
        c.pointsize 115
        c.draw "text 150,1300 'Example:'"

        # Example text
        c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
        c.pointsize 95
        c.draw "text 150,1400'#{parse_example}'"
      end
    end
  end

  def output_image
    @image.write @filename
  end
end