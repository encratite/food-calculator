require 'FoodCalculator'

if ARGV.size != 1
	puts 'Usage:'
	puts "ruby #{File.basename(__FILE__)} <consumption file>"
	exit
end

path = ARGV[1]
begin
	calculator = FoodCalculator.new('food-definitions')
	energy = calculator.processConsumptionFile(path)
	puts "#{energy.to_i} kJ"
rescue RuntimeError => error
	puts "Error: #{error.message}"
end
