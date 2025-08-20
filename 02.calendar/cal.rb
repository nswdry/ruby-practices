#!/usr/bin/env ruby

require 'date'
require 'optparse'

options = {}
opt = OptionParser.new

opt.on('-y YEAR', Integer) {|year| options[:year] = year}
opt.on('-m MONTH', Integer) {|month| options[:month] = month}

opt.parse!(ARGV)

year = options[:year] || Date.today.year
month = options[:month] || Date.today.month

first_date = Date.new(year, month, 1)
last_date = Date.new(year, month, -1)

puts "      #{month}月 #{year}"
puts "日 月 火 水 木 金 土"
print "   " * first_date.wday

(first_date..last_date).each do |date|
  print date.day.to_s.rjust(2)
  if date.saturday? || date == last_date
    puts
  else
    print " "
  end
end
