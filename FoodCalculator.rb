require 'nil/file'

require_relative 'FoodDefinition'
require_relative 'EnergyEntry'

class FoodCalculator
  def initialize(configurationPath)
    @definitions = []
    readConfiguration configurationPath
  end

  def readConfiguration(path)
    pattern = /(.+) (\d+|\d+\.\d+) kJ(\/(\d+|\d+\.\d+)(g|kg))?/
    lines = Nil.readLines(path)
    if lines == nil
      raise "Unable to open configuration file #{path}"
    end
    counter = 1
    lines.each do |line|
      next if line.empty?
      match = pattern.match(line)
      if match == nil
        raise "Invalid entry in configuration file #{path} on line #{counter}: #{line}"
      end
      name = match[1]
      energy = match[2].to_f
      amount = match[4]
      unit = match[5]
      if amount == nil
        definitionAmount = nil
      else
        definitionAmount = [amount.to_f, unit]
      end
      definition = FoodDefinition.new(name, energy, definitionAmount)
      @definitions << definition
      counter += 1
    end
  end

  def processConsumptionFile(path)
    pattern = /((\d+|\d+\.\d+)(g|kg)?) (.+)/

    totalEnergy = 0.0

    lines = Nil.readLines(path)
    if lines == nil
      raise "Unable to open consumption file #{path}"
    end

    entries = []

    counter = 1
    lines.each do |line|
      next if line.empty?
      match = pattern.match(line)
      if match == nil
        raise "Invalid entry in consumption file #{path} on line #{counter}: #{line}"
      end
      amount = match[2].to_f
      unit = match[3]
      name = match[4]

      index = @definitions.index(name)
      if index == nil
        raise "Unable to find a food definition for food \"#{name}\" on line #{counter}"
      end

      definition = @definitions[index]

      isNonMassAmount = unit == nil
      definitionIsNonMassAmount = definition.amount == nil
      if isNonMassAmount != definitionIsNonMassAmount
        raise "Incompatible units specified for food \"#{definition.name}\" on line #{counter}"
      end

      energy = amount * definition.energy
      if !isNonMassAmount
        #amount /= 1000.0
        energy *= FoodDefinition::MassUnits[unit] / definition.amount
      end
      energy /= 1000.0
      #puts "Energy for #{line}: #{energy} kJ"

      entries << EnergyEntry.new(line, energy)

      totalEnergy += energy

      counter += 1
    end

    padding = entries.map{|x| x.description.size}.max + 5

    entries.sort.each do |entry|
      printf("#{entry.description}: %#{padding - entry.description.size}d kJ\n", entry.energy)
    end

    totalEnergy = totalEnergy
    return totalEnergy
  end
end
