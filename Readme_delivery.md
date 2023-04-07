## SOLUTION - See Challenge Proposal below
### 1. Tooling basics
This Car Pooling API solution is built in Ruby. It uses Sinatra as gateway,
delegating requests to pure Ruby classes

To solve the challenge, two "roles" were recognized to be fulfilled
simultaneously:

(i) the journey requester, which performs a request and **must** wait
for response, (ii) the journey finder, which takes care of finding journeys
but should not demand trip resolving in order before the next ones.
At the same it should not leave unresolved trips unattended.

The application is served using puma(multi-threaded Ruby server) to
take advantage of simultaneous connections and multi-thread computing. This
allows multiple requesters to wait and the first role to be fulfilled.
The second role is fulfilled by running a periodic journey finder implemented
using concurrent computation and enforcing Thread safe code for atomic
operations.

### 2. Serving cars
Journeys can be created via request and are managed by a queue. Once
a car is requested, the requested posts to a CarPoolingQueue. The request
then sleeps and keeps trying to find a CarFoundNotification
for the waiting group. This notification contains a car_id that may carry out
the trip.

Once the waiting request detects that a car has been found for
that waiting group, it atomically registers the journey, subtracts the number
of seats from the assigned car, removes the notification and
returns a 200 status.

### 3. The CarPolling queue
The queue runs concurrently as a scheduled task, that periodically loops
through the queue, finds cars, and notifies the awaiting requesters.

It serves cars on a first-come-first-serve(FCFS) order. Once the
consumer starts, it assigns cars to customers in order of
arrival(i.e.: it loops through the queue).

However, it would not be fair for example within a queue context,
for every customer to need to be served before the next, since we don't
know how long that could take. As a workaround, the queue stores and skips
unresolved waiting groups, retrying them before attempting to solve the
next waiting groups, so they get prioritized and don't have to wait for
another queue cycle to start to get a journey registered.

Cars are served until they are full(i.e.: until no more sits are available).
Cars are served to customers FSFS using optimal fit first: we can't fit 4
people in a car with 2-seats. Since the opposite is true, makes sense to try
to fit groups in the largest possible cars and generate the most journeys
possible. If we can't find an exact fit, we find a larger car.

### 4. Thread-safety
Thread safety is achieved by using Thread-synced(i.e.: Thread-safe) variables
implemented by concurrent-ruby. Atomic transactions are performed using Mutual
Exclusion(Mutex) locks in certain points of the code.

### 4. Rationale behind the tooling/solution
As the first boundary condition, no databases are allowed. Hence
storage must be done into process memory or using a file-based
approach. Since a file-based solution would require loading data
into the memory anyway, class variables were selected.
One of the key points was data storage using key pointers(hashes)
instead of indexes(arrays) unless no other choice is possible,
mainly to avoid array-looping operations.

The second boundary condition is serving customers by arrival order.
This means that we need something to happen continuously and assign
cars to customers in order. Practically this has been implemented as a
ScheduledTask, scheduled for immediate execution. This task runs
in a separate Thread, and will loop through the queue, find cars and
post notifications to waiting customers. We use two main abstractions for
encapsulation: one for queue state(TimerTask - kinda like a daemon)
and another for queue execution(ScheduledTask).

Rack-based applications, such as Sinatra, typically serve using
multiple threads. Since Ruby threads are allowed to wait and each process
could range up to 200/300 simultaneous threads, using multi-threading
requests and making them wait seems like a reasonable choice.

Ruby is my language of choice since it is the one I know most
to better solve this challenge. Although I have to admit it is probably not the
best one. The solution described above could work faster and better on
a language like Go, where parallel computing is possible and potentially not
so much of a hassle. Ruby only allows concurrent computing, implementing a
Global Interpreter Lock which interleaves code execution, but presents
Thread Safety challenges.

Another caveat is that Ruby implements native threading. However, thread-safe
code is rather(according to my research) difficult and lacks implementation
standards(i.e.: Promises, ScheduledTasks, TimerTasks, etc...). Consequently,
using wrappers to assist the creation of Thread safe code is advised.
Hence I used the concurrent-ruby gem.

By coupling multi-threaded requests that can wait and be resolved
somehow and a class that acts as a journey finder we can provide:
(i)trips in order, (ii)prevent the journey finder to keep finding
trips if a waiting group still does not have a car available,
(iii)prevent the customer from waiting and not getting his
request periodically checked.

### 4. How did I achieve a large number of cars/waiting groups

The tooling was thought end-to-end to be the state of the art on what
is available on Ruby and uses decoupling abstractions sufficient so that the
code is changeable given a new set of specifications or an upscale necessity.
We use puma to handle requests concurrently, which is basically an obvious
choice. Concurrent computing becomes necessary given the problem abstraction
that was chosen and a set of abstractions inherently necessary. Hence not much
choice was given there, only optimization was allowed within the toolkit we
chose.

Scale assertion was performed using the `performance_tester.rb` snippet(it does
not look good, I didn't have time to make it look pretty). Using the maximum
concurrency limit recommended by ruby(around 200 simultaneous threads),
we are capable of resolving(at least on my machine) 500 trips per minute when
testing in-line. Concurrently we are capable of processing up to 2600 trips
per minute.