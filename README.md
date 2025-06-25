# Word of the Day

WODGen is a ruby script that generates a Word of the Day image for posting to social media.

It utilizes https://api.dictionaryapi.dev to gather word usages and definitions an present them to 
the user in a commandline environment such that the user may choose which definition of a word to use 
in the creation of the image.  Once the user picks the word to use, the script then utilizes the mini_magick 
gem to package the chosen word, definition, and usage along with the image listed in assets/ .


