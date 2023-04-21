require 'byebug'

cars = {
    seats:{
        "0" => [],
        "1" => (Array.new(150_000) { rand(1...150_000) }).uniq,
        "2" => (Array.new(150_000) { rand(150_000...300_000) }).uniq,
        "3" => (Array.new(150_000) { rand(300_000...450_000) }).uniq,
        "4" => (Array.new(150_000) { rand(300_000...450_000) }).uniq,
    }
}

iter = 0 
wanted_journeys = []
while iter < 400_000
    iter += 1
    wanted_journeys << { wgid:iter, people: rand(1..4) }
end

journeys = {}

start = Time.now
for wanted_journey in wanted_journeys
    max_cars_seats = cars[:seats].keys.map(&:to_i).max
    for nseats in wanted_journey[:people]..max_cars_seats
        car_id = cars[:seats][wanted_journey[:people].to_s].first
        if car_id
            journeys[wanted_journey[:wgid].to_s] = car_id
            remaining_seats = nseats - wanted_journey[:people]
            cars[:seats][wanted_journey[:people].to_s].shift
            cars[:seats][remaining_seats.to_s] << car_id
        end
    end
end
stop = Time.now
time = stop - start

puts "took #{time} s to run"
puts journeys.count