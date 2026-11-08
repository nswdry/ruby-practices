# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :shots

  def initialize
    @shots = []
  end

  def throw(pins)
    shots << Shot.new(pins)
  end

  def strike?
    !!shots.first&.strike?
  end

  def spare?
    return false if strike?

    shots.size == 2 && shots.sum(&:pins) == 10
  end

  def complete?
    strike? || shots.size == 2
  end

  def base_score
    shots.sum(&:pins)
  end

  def score(frames, shot_index)
    all_pins = frames.flat_map(&:shots).map(&:pins)
    next_index = shot_index + shots.size

    bonus = if strike?
              all_pins[next_index, 2].sum
            elsif spare?
              all_pins[next_index]
            else
              0
            end

    base_score + bonus
  end
end

class LastFrame < Frame
  def complete?
    if shots.size == 3
      true
    elsif shots.size < 2
      false
    else
      !(strike? || spare?)
    end
  end
end
