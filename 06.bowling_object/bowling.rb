#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game'

def convert(shot)
  shot == 'X' ? 10 : shot.to_i
end

shots = ARGV[0].split(',').map { |s| convert(s) }

game = Game.new
shots.each { |pins| game.add_shot(pins) }

puts game.score
