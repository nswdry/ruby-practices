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
  width = IO.console.winsize[1]
  max_length = files.map(&:length).max
  cols = calc_columns(width, max_length)
  if params[:l]
    display_long(files)
  else
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

def display_long(files)
  files.each do |file|
    st = File.stat(file)
    puts format_long_line(file, st)
  end
end

def format_long_line(file, st)
  type        = file_type(st.ftype)
  permission  = format_mode(st)
  link        = st.nlink
  user_name   = Etc.getpwuid(st.uid).name
  group_name  = Etc.getgrgid(st.gid).name
  size        = st.size

  last_updated =
    if st.mtime.to_date >= Date.today << 6
      st.mtime.strftime('%_m %_d %H:%M')
    else
      st.mtime.strftime('%_m %_d %Y')
    end

  format '%s%s %3d %-2s %-7s %d %11s',
         type, permission, link, user_name, group_name, size, last_updated
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

def format_mode(st)
  permission_bits = [
    { r: 0o400, w: 0o200, x: 0o100, special: 0o4000, exec: %w[s S] },
    { r: 0o040, w: 0o020, x: 0o010, special: 0o2000, exec: %w[s S] },
    { r: 0o004, w: 0o002, x: 0o001, special: 0o1000, exec: %w[t T] }
  ]

  permission_bits.map do
    r = st.mode & it[:r] != 0 ? 'r' : '-'
    w = st.mode & it[:w] != 0 ? 'w' : '-'
    x = st.mode & it[:x] != 0 ? 'x' : '-'

    if st.mode & it[:special] != 0
      x = x == 'x' ? it[:exec][0] : it[:exec][1]
    end

    "#{r}#{w}#{x}"
  end.join
end

main(params)
