# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :shots

  def initialize
    @shots = []
  end

  def add_shot(pins)
    shots << Shot.new(pins)
  end

  def strike?
    shots.first&.strike? || false
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
