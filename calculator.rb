require 'nil/file'

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
			@amount = mass * unitFactor
		end
	end
	
	def ==(input)
		return @name.downcase == input.downcase
	end
end

class FoodCalculator
	def initialize(configurationPath)
		@definitions = []
		readConfiguration configurationPath
	end
	
	def readConfiguration(path)
		pattern = /(.+) (\d+|\d+\.\d+) kJ(/(\d+|\d+\.\d+)(g|kg))?/
		lines = Nil.readLines(path)
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
	end
end
