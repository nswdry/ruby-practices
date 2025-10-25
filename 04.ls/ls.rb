#!/usr/bin/env ruby
# frozen_string_literal: true

require 'io/console'
require 'optparse'
opt = OptionParser.new

params = {}

opt.on('-a') { params[:a] = true }
opt.on('-r') { params[:r] = true }
opt.parse(ARGV)

def main(params)
  files = fetch_dir_contents(params)
  width = IO.console.winsize[1]
  max_length = files.map(&:length).max
  cols = calc_columns(width, max_length)
  display_in_columns(files, cols, max_length)
end

def fetch_dir_contents(params)
  Dir.glob('*', params[:a] ? File::FNM_DOTMATCH : 0)
     .then { params[:r] ? it.reverse : it }
end

def calc_columns(width, max_length)
  (width / (max_length + 1)).floor.clamp(1, 3)
end

def display_in_columns(files, cols, max_length)
  row_count = files.size.ceildiv(cols)
  rows = files.each_slice(row_count).map { |slice| slice.fill('', slice.size...row_count) }.transpose

  rows.each do |row|
    puts row.map { |f| f.ljust(max_length) }.join(' ')
  end
end

main(params)
