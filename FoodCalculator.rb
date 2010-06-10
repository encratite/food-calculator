require 'nil/file'

require 'FoodDefinition'

class FoodCalculator
	def initialize(configurationPath)
		@definitions = []
		readConfiguration configurationPath
	end
	
	def readConfiguration(path)
		pattern = /(.+) (\d+|\d+\.\d+) kJ(/(\d+|\d+\.\d+)(g|kg))?/
		lines = Nil.readLines(path)
		if lines == nil
			raise "Unable to open configuration file  #{path}"
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
			amount = match[4].to_f
			unit = match[5]
			if amount == nil
				definitionAmount = nil
			else
				definitionAmount = [amount, unit]
			else
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
			raise "Unable to open consumption file  #{path}"
		end
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
			
			definition = @definitions.index(name)
			if definition == nil
				raise "Unable to find a food definition for food \"#{definition.name}\" on line #{counter}"
			end
			
			isNonMassAmount = unit == nil
			definitionIsNonMassAmount = definition.amount == nil
			if isNonMassAmount != definitionIsNonMassAmount
				raise "Incompatible units specified for food \"#{definition.name}\" on line #{counter}"
			end
			
			energy = amount * definition.energy
			if !isNonMassAmount
				energy *= amount FoodDefinition::MassUnits[unit]
			end
			totalEnergy += energy
			
			counter += 1
		end
		
		return totalEnergy
	end
end
