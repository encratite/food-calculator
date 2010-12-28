class FoodDefinition
  attr_reader :name, :energy, :amount

  MassUnits =
    {
    'kg' => 1.0,
    'g' => 1 / 1000.0,
  }

  #energy in kilojoule
  #unit indicates for what unit of food this measure is valid
  #a amount of nil indicates that this definition is for the consumption of one average sized specimen
  #a amount of [100, 'g'] would imply a mass of 0.1 kg
  def initialize(name, energy, amount)
    @name = name
    #internally everything is stored as J, not kJ
    @energy = energy * 1000.0

    if amount == nil
      @amount = nil
    else
      #internally everything is stored as kg
      mass, unit = amount
      unitFactor = MassUnits[unit]
      if unitFactor == nil
        raise "Invalid unit: #{unit.inspect}"
      end
      @amount = mass * unitFactor
    end
  end

  def ==(input)
    return @name.downcase == input.downcase
  end
end
