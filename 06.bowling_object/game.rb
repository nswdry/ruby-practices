# frozen_string_literal: true

require_relative 'frame'

class Game
  FRAME_COUNT = 10

  def initialize
    @frames = Array.new(FRAME_COUNT - 1) { Frame.new } + [LastFrame.new]
  end

  def add_shot(pins)
    current_frame = @frames.find { |frame| !frame.complete? }
    current_frame.add_shot(pins)
  end

  def score
    all_pins = @frames.flat_map(&:shots).map(&:pins)
    shot_index = 0
    total = 0

    @frames.each do |frame|
      total += if frame.equal?(@frames.last)
                 frame.base_score
               elsif frame.strike?
                 10 + all_pins[shot_index + 1, 2].sum
               elsif frame.spare?
                 10 + all_pins[shot_index + 2]
               else
                 frame.base_score
               end

      shot_index += frame.shots.size
    end

    total
  end
end
