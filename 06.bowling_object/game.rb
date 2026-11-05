# frozen_string_literal: true

require_relative 'frame'

class Game
  FRAME_COUNT = 10

  def initialize
    @frames = Array.new(FRAME_COUNT - 1) { Frame.new } + [LastFrame.new]
  end

  def throw(pins)
    current_frame = @frames.find { |frame| !frame.complete? }
    current_frame.throw(pins)
  end

  def score
    all_pins = @frames.flat_map(&:shots).map(&:pins)
    shot_index = 0
    total = 0

    @frames.each do |frame|
      total += frame.score(all_pins, shot_index)
      shot_index += frame.shots.size
    end

    total
  end
end
