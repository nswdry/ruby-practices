# frozen_string_literal: true

class Shot
  attr_reader :pins

  def initialize(pins)
    @pins = pins
  end

  def strike?
    pins == 10
  end
end
