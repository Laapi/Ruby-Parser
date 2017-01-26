require_relative 'dependencies/options'
require_relative 'dependencies/parser'

puts 'Enter link to the category page.'
link = gets.chomp

puts 'Enter result file name.'
file = gets.chomp

options = Options.new({link: link, file: file})
puts "Run parser with this parameters: \n Link: #{options.link} \n Filename: #{options.file}"
 
parser = Parser.new(options)