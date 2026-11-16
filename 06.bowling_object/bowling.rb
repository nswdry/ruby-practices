#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game'

shots = ARGV[0].split(',').map { |s| Shot.convert(s) }

game = Game.new
shots.each { |shot| game.throw(shot) }

puts game.score
