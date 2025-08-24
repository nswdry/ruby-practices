#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  shots << if s == 'X' # strike
             10
           else
             s.to_i
           end
end

i = 0
point = 0

(1..10).each do |frame|
  if frame < 10
    if shots[i] == 10 # 　strike
      point += 10 + shots[i + 1] + shots[i + 2]
      i += 1
    elsif shots[i] + shots[i + 1] == 10 # 　spare
      point += 10 + shots[i + 2]
      i += 2
    else
      point += shots[i] + shots[i + 1]
      i += 2
    end
  else
    point += shots[i..].sum # 10フレーム目
  end
end

puts point
