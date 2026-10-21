#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game'

def convert(shot)
  shot == 'X' ? 10 : shot.to_i
end

shots = ARGV[0].split(',').map { |s| convert(s) }

game = Game.new
shots.each { |shot| game.add_shot(shot) }

puts game.score
