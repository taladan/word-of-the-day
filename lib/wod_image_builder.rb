#!/usr/bin/env ruby
# frozen_string_literal: true


class ImageBuilder
  def initialize(word, usage, definition)
    @word = word
    @usage = usage
    @definition = definition
    @background_images = './assets/'
    @page_title = 'Word of the Day...'
    @image = MiniMagick::Image.open(get_background_image)
    seconds_since_midnight = Time.now.to_i % 86400 
    @filename = "#{@word}_#{seconds_since_midnight}.jpg"
    draw_image
    output_image
    puts "#{@filename} written"
  end
  
  private

  # wrap definition at appropriate width for image
  def parse_definition
    WordWrap.ww(@definition, width=50)
  end

  def get_background_image
    Dir.glob("#{@background_images}*.jpg").sample
  end
  # Draw each element with text formatting
  def draw_image
    @image.combine_options do |c| 
      # Title shadow
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
      c.style 'Bold'
      c.style 'Italic'
      c.fill '#03030350'
      c.pointsize 141
      c.draw "text 155,205 '#{@page_title}'"

      # Title
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-DemiItalic.otf'
      c.style 'Bold'
      c.style 'Italic'
      c.fill 'black'
      c.pointsize 141
      c.draw "text 150,200 '#{@page_title}'"

      # Word dropshadow
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
      c.style 'Bold'
      c.fill '#05050580'
      c.pointsize 100
      c.draw "text 155,505 '#{@word}'"

      # Word
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Demi.otf'
      c.style 'Bold'
      c.fill 'black'
      c.pointsize 100
      c.draw "text 150,500 '#{@word}'"

      # Grammatical Usage
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
      c.pointsize 50
      c.draw "text 150,575 '(#{@usage})'"

      # Definition
      c.font '/usr/share/fonts/opentype/urw-base35/URWBookman-Light.otf'
      c.pointsize 55
      c.draw "text 150,750'#{parse_definition}'"
    end
  end

  def output_image
    @image.write @filename
  end
end