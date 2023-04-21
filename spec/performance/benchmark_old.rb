require 'byebug'
iter = 0
cars = []
while iter < 400_000
    iter += 1
    cars <<
    {
        id: iter,
        seats: rand(1..4)
    }
end

iter = 0 
wanted_journeys = []
while iter < 400_000
    iter += 1
    wanted_journeys << { wgid:iter, people: rand(1..4) }
end

journeys = {}
max_car_seats = 4

start = Time.now
for wanted_journey in wanted_journeys
    car = cars.find{ |el| el[:seats] == wanted_journey[:people] }
    if car
        car = cars.find{ |el| el[:id] == car[:id] }

        journeys[wanted_journey[:wgid].to_s] = car[:id]
        remaining_seats = car[:seats] - wanted_journey[:people]
        car[:seats] -= remaining_seats
    end
end
stop = Time.now
time = stop - start

puts "took #{time} s to run"
puts journeys.count