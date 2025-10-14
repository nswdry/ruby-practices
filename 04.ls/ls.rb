#!/usr/bin/env ruby
# frozen_string_literal: true

require 'io/console'

def main
  files = fetch_dir_contents
  width = IO.console.winsize[1]
  max_length = files.map(&:length).max
  cols = calc_columns(width, max_length)
  display_in_columns(files, cols, max_length)
end

def fetch_dir_contents
  Dir.glob('*')
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

main
