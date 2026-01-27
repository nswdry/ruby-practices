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
  results << calculate_total(columns, results) if results.size > 1
  field_widths = calculate_field_widths(columns, results)
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

def calculate_total(columns, results)
  total = columns.each_with_object({}) do |col, total|
    total[col] = results.sum { it[col] }
  end

  total[:file] = 'total'
  total
end

def calculate_field_widths(columns, results)
  min_width = 7

  columns.each_with_object({}) do |col, widths|
    widths[col] = [results.map { it[col] }.max.to_s.length, min_width].max
  end
end

def print_results(results, field_widths, columns)
  results.each do |row|
    columns.each do |col|
      print " #{row[col].to_s.rjust(field_widths[col])}"
    end
    puts row[:file] && " #{row[:file]}"
  end
end

main(files, params)
