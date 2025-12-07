#!/usr/bin/env ruby
# frozen_string_literal: true

require 'io/console'
require 'optparse'
require 'etc'
require 'date'
opt = OptionParser.new

params = {}

opt.on('-a') { params[:a] = true }
opt.on('-r') { params[:r] = true }
opt.on('-l') { params[:l] = true }
opt.parse(ARGV)

def main(params)
  files = fetch_dir_contents(params)
  stat = files.to_h { [it, File.lstat(it)] }

  if params[:l]
    display_long(files, stat)
  else
    width = IO.console.winsize[1]
    max_length = files.map(&:length).max
    cols = calc_columns(width, max_length)
    display_in_columns(files, cols, max_length)
  end
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

def display_long(files, stat)
  total_blocks = stat.values.sum(&:blocks)
  puts "total #{total_blocks}"

  link_width = stat.values.map { it.nlink.to_s.length }.max
  user_width = stat.values.map { Etc.getpwuid(it.uid).name.length }.max
  group_width = stat.values.map { Etc.getgrgid(it.gid).name.length }.max
  size_width = stat.values.map { it.size.to_s.length }.max

  field_widths = {
    link: link_width,
    user: user_width,
    group: group_width,
    size: size_width
  }

  files.each do
    puts format_long_line(it, stat[it], field_widths)
  end
end

def format_long_line(file, stat, field_widths)
  type = file_type(stat.ftype)
  permission = format_mode(stat)
  link = stat.nlink
  user_name  = Etc.getpwuid(stat.uid).name
  group_name = Etc.getgrgid(stat.gid).name
  size = stat.size

  last_updated =
    if stat.mtime.to_date >= Date.today << 6
      stat.mtime.strftime('%_m %_d %H:%M')
    else
      stat.mtime.strftime('%_m %_d %Y')
    end

  format "%s%s  %-#{field_widths[:link]}d %#{field_widths[:user]}s  %#{field_widths[:group]}s  %#{field_widths[:size]}d %s %s",
         type, permission, link, user_name, group_name, size, last_updated, file
end

def file_type(ftype)
  {
    'file' => '-',
    'directory' => 'd',
    'characterSpecial' => 'c',
    'blockSpecial' => 'b',
    'fifo' => 'p',
    'link' => 'l',
    'socket' => 's'
  }.fetch(ftype, '?')
end

def format_mode(stat)
  permission_bits = [
    { r: 0o400, w: 0o200, x: 0o100, special: 0o4000, exec: %w[s S] },
    { r: 0o040, w: 0o020, x: 0o010, special: 0o2000, exec: %w[s S] },
    { r: 0o004, w: 0o002, x: 0o001, special: 0o1000, exec: %w[t T] }
  ]

  permission_bits.map do
    r = stat.mode & it[:r] != 0 ? 'r' : '-'
    w = stat.mode & it[:w] != 0 ? 'w' : '-'
    x = stat.mode & it[:x] != 0 ? 'x' : '-'

    if stat.mode & it[:special] != 0
      x = x == 'x' ? it[:exec][0] : it[:exec][1]
    end

    "#{r}#{w}#{x}"
  end.join
end

main(params)
