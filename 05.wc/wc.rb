#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

opt = OptionParser.new
params = {}

opt.on('-l') { params[:l] = true }
opt.on('-w') { params[:w] = true }
opt.on('-c') { params[:c] = true }

opt.parse!(ARGV)

files = ARGV.empty? ? [$stdin] : ARGV

def main(files, params)
  columns = select_columns(params)
  results = fetch_files(files)
  results << calculate_total(results) if results.size > 1
  field_widths = calculate_field_widths(results)
  print_results(results, field_widths, columns)
end

def select_columns(params)
  return %i[line word byte] if params.values.none?

  cols = []
  cols << :line if params[:l]
  cols << :word if params[:w]
  cols << :byte if params[:c]
  cols
end

def fetch_files(files)
  files.map do |file|
    content = file == $stdin ? $stdin.read : File.read(file)
    {
      line: content.lines.size,
      word: content.split.size,
      byte: content.bytesize,
      file: file == $stdin ? nil : file
    }
  end
end

def calculate_total(results)
  {
    line: results.sum { it[:line] },
    word: results.sum { it[:word] },
    byte: results.sum { it[:byte] },
    file: 'total'
  }
end

def calculate_field_widths(results)
  min_width = 7

  line = [results.map { it[:line] }.max.to_s.length, min_width].max
  word = [results.map { it[:word] }.max.to_s.length, min_width].max
  byte = [results.map { it[:byte] }.max.to_s.length, min_width].max

  { line:, word:, byte: }
end

def print_results(results, field_widths, columns)
  results.each do |row|
    columns.each do |col|
      printf " %#{field_widths[col]}d", row[col]
    end
    puts row[:file] ? " #{row[:file]}" : nil
  end
end

main(files, params)
