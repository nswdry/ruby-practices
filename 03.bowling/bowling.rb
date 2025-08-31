#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
shots = score.split(',').flat_map { |s| s == 'X' ? 10 : s.to_i }

i = 0

point = (1..9).sum do
  if shots[i] == 10 # 　strike
    flame_score = 10 + shots[i + 1] + shots[i + 2]
    i += 1
  elsif shots[i] + shots[i + 1] == 10 # 　spare
    flame_score = 10 + shots[i + 2]
    i += 2
  else
    flame_score = shots[i] + shots[i + 1]
    i += 2
  end
  flame_score
end

point += shots[i..].sum # 10フレーム目

puts point
