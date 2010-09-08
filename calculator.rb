require_relative 'FoodCalculator'

if ARGV.size != 1
	puts 'Usage:'
	puts "ruby #{File.basename(__FILE__)} <consumption file>"
	exit
end

path = ARGV[0]
begin
	calculator = FoodCalculator.new('food-definitions')
	energy = calculator.processConsumptionFile(path)
	puts "Total: #{energy.to_i} kJ"
rescue RuntimeError => error
	puts "Error: #{error.message}"
end
