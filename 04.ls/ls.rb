def fetch_dir_contents
  Dir.glob("*")
end

def calc_columns(width, max_length)
  if width < 2 * (max_length + 1)
    1
  elsif width < 3 * (max_length + 1)
    2
  else
    3
  end
end

def display_in_columns(files, cols, max_length)
  row_count = (files.size / cols.to_f).ceil
  rows = files.each_slice(row_count).map{ |slice| slice.fill("", slice.size...row_count)}.transpose

  rows.each do |row|
    puts row.map{ |f| f.ljust(max_length)}.join(" ")
  end
end
