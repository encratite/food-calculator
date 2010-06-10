class EnergyEntry
	attr_reader :description, :energy
	
	def initialize(description, energy)
		@description = description
		@energy = energy
	end
	
	def <=>(input)
		return input.energy <=> @energy
	end
end
