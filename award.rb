require 'pry'

module Awards
  class Base
    AWARD_MAX = 50
    AWARD_MIN = 0

    attr_accessor :name, :expires_in, :quality

    def initialize(opts)
      @expires_in = opts[:expires_in]
      @name       = opts[:name]
      @quality    = opts[:quality]
    end

    def update_quality!
      fail 'To be implemented by subclass'
    end

    private

    def change_quality_by(number)
      _quality = @quality + number

      _quality = (_quality >= AWARD_MAX) ? AWARD_MAX : _quality
      _quality = (_quality <= AWARD_MIN) ? AWARD_MIN : _quality

      @quality = _quality
    end

    def decrease_expires_in
      @expires_in = @expires_in - 1
    end
  end

  class BlueFirst < Base
    def update_quality!
      if expires_in <= 0
        change_quality_by(+2)
      else
        change_quality_by(+1)
      end

      decrease_expires_in
    end
  end

  class BlueDistinctionPlus < Base
    def update_quality!
      @quality = 80
    end
  end

  class BlueCompare < Base
    def update_quality!
      if expires_in <= 0
        @quality = 0
      elsif (1..5).include?(expires_in)
        change_quality_by(+3)
      elsif (6..10).include?(expires_in)
        change_quality_by(+2)
      else
        change_quality_by(+1)
      end

      decrease_expires_in
    end
  end

  class BlueStar < Base
    def update_quality!
      if expires_in <= 0
        change_quality_by(-4)
      else
        change_quality_by(-2)
      end

      decrease_expires_in
    end
  end

  class NormalItem < Base
    def update_quality!
      if expires_in <= 0
        change_quality_by(-2)
      else
        change_quality_by(-1)
      end

      decrease_expires_in
    end
  end
end

class ConstructedAwardClass
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_class_name
    klass = name.split.map(&:capitalize).join
    "Awards::#{klass}"
  end
end

#
# Since we're using this API elsewhere we need
# to preserve the existing interface.
#
# Award.new(name, initial_expires_in, initial_quality)
#
module Award
  def self.new(name, initial_expires_in, initial_quality)
    klass = ConstructedAwardClass.new(name).to_class_name

    Object.const_get(klass).new(
      expires_in: initial_expires_in,
      quality: initial_quality,
      name: name,
    )
  end
end
