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
