class Datum
  attr_accessor :label, :time, :x, :y, :extra, :extra_2

  def initialize(attributes)
    attributes.each {|key, value| self.send((key.to_s + "=").to_sym, value)}
  end
end