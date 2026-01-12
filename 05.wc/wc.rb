# frozen_string_literal: true

require 'optparse'

ARGV.getopts('l', 'w', 'c')
files = ARGV

def main(files)
  results = fetch_files(files)
  field_widths = calculate_field_widths(results)
  print_results(results, field_widths)
end

def fetch_files(files)
  files.map do |file|
    content = File.read(file)
    {
      line: content.lines.size,
      word: content.split.size,
      byte: content.bytesize,
      file: file
    }
  end
end

def calculate_field_widths(results)
  min_width = 7

  line = [results.map { it[:line] }.max.to_s.length, min_width].max
  word = [results.map { it[:word] }.max.to_s.length, min_width].max
  byte = [results.map { it[:byte] }.max.to_s.length, min_width].max

  { line:, word:, byte: }
end

def print_results(results, field_widths)
  results.each do
    printf " %#{field_widths[:line]}d %#{field_widths[:word]}d %#{field_widths[:byte]}d %s\n", it[:line], it[:word], it[:byte], it[:file]
  end
end

main(files)
