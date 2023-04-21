# ab -n 1000 -c 10 http://127.0.0.1:9292/status
require 'byebug'
cars = {
        "0" => [],
        "1" => (Array.new(150_000) { rand(1...150_000) }).uniq,
        "2" => (Array.new(150_000) { rand(150_000...300_000) }).uniq,
        "3" => (Array.new(150_000) { rand(300_000...450_000) }).uniq,
        "4" => (Array.new(150_000) { rand(300_000...450_000) }).uniq
}

trips = []
ntripstocreate = 400_000

(1..ntripstocreate).each do |id|
    trips << {
        'group_id' => id,
        'people' => rand(1..4) 
    }
end

journeys = []

start = Time.now
max_car_seats = cars.keys.sort.last.to_i

trips.each do |trip|
    for car_seats in trip['people']..max_car_seats
        
        car_seats_as_str = car_seats.to_s
        car_id = cars[car_seats_as_str].first
        if car_id 
            journeys << { 
                'car_id' => car_id, 
                'group_id' => trip['group_id'] 
            }
            new_seats = car_seats - trip['people']
            cars[car_seats_as_str].shift
            cars[new_seats.to_s] << car_id
        end
    end
end

stop = Time.now
puts "#{trips.length} trips assigned in #{(stop - start).round(2)} seconds"