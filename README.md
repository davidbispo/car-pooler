## SOLUTION - See Challenge Proposal below

### 1. Tooling basics
This Car Pooling API solution is built in Ruby. It uses Sinatra as gateway,
delegating requests to pure Ruby classes

To solve the challenge, two "roles" were recognized to be fulfilled
simultaneously:

(i) the journey requester, which performs a request and **can** wait 
for response, (ii) the journey finder, which takes care of finding journeys 
but not demanding trip resolving in order before the next ones. At the same 
time not leaving unresolved trips unattended.

The application is served using puma(multi-threaded Ruby server) to 
take advantage of simultaneous connections and multi-thread computing, allowing
multiple requesters to wait. The other role is fulfilled running a periodic 
journey finder implemented using concurrent computation and enforcing Thread 
safe code on atomic operations.

### 2. Serving cars
Journeys can be created via request and are managed by a queue. Once
a car is requested, the requested posts to a CarPooling queue. The request 
request sleeps and retries finding a CarFoundNotification for the waiting group.
This notification contains a car_id possible to carry out the trip.

Once the waiting request detects that a car has been found for 
that waiting group, it atomically registers the journey, subtracts
car seats from the assigned car and returns a 200 status.

### 3. The CarPolling queue
The queue runs as concurrent a scheduled task that periodically loops
through the queue, finds cars, and notifies the awaiting requesters.

The concurrency patterns are implemented by concurrent-ruby.

It serves cars on a first-come first-serve(FCFS) order. Once the 
consumer starts, it assigns cars to customers in order of arrival. 

However, it would not be fair for example, to await car assignment to 
serve a 6-people waiting group and leave other customers waiting. 
As a workaround, the queue stores and skips unresolved waiting groups 
and retries them before attempting to solve the next waiting groups, 
so they get higher priority and don't have to wait for another queue cycle 
to start to get a journey registered.

Cars are served until they are full(i.e.: until no more sits are available). 
Cars are served to customers FSFS using optimal fit first:we can't fit 4 
people in a car with 2-seats. since the opposite is true, makes sense to always fit larger
groups in the largest possible cars. If we can't find an exact fit we find a 
larger car.

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
cars to customers in order. Practically this has been implemented as Timer task 
which periodically checks if the queue is being executed. Case not, a 
ScheduledTask is scheduled for immediate execution(in a separate Thread) 
which will loop loop through the queue, finds cars and posts notifications 
to waiting customers. We use these two abstractions to allow encapsulation 
of queue state(TimerTask) and queue execution(ScheduledTask).

Rack-based applications, such as Sinatra, typically serve using
multiple threads. Since Ruby threads are allowed to wait and each process
could range up to 200/300 simultaneous threads, using multi-threading
requests and making them wait seems like a reasonable choice.

Ruby is my primary language and the one I know most optimization tools
to solve this challenge, although I have to admit it is probably not the
best one. The solution described above could work faster and better on 
a language like Go, where parallel computing is possible and potentially not
so much of a hassle. Ruby only allows concurent computing, implementing a 
Global Interpreter Lock which interleaves code execution, but also presents 
Thread Safety challenges.

Another caveat is that Ruby implements native threading. However, thread-safe 
code is rather(according to my research) difficult and lacks implementation 
standards(i.e.: Promises, ScheduledTasks, TimerTasks, etc...). Consequently,
using wrappers to assist the creation of Thread safe code is advides.
Hence I used the concurrent-ruby gem.

By coupling multi-threaded requests that can wait and be resolved
somehow and a class that acts as a journey finder we can provide:
(i)trips in order, (ii)prevent the journey finder to keep finding 
trips if a waiting group still does not have a car available,
(iii)prevent the customer from waiting and not getting his
request periodically checked.

# Car Pooling Service Challenge

Design/implement a system to manage car pooling.

At Cabify we provide the service of taking people from point A to point B.
So far we have done it without sharing cars with multiple groups of people.
This is an opportunity to optimize the use of resources by introducing car
pooling.

You have been assigned to build the car availability service that will be used
to track the available seats in cars.

Cars have a different amount of seats available, they can accommodate groups of
up to 4, 5 or 6 people.

People requests cars in groups of 1 to 6. People in the same group want to ride
on the same car. You can take any group at any car that has enough empty seats
for them. If it's not possible to accommodate them, they're willing to wait until 
there's a car available for them. Once a car is available for a group
that is waiting, they should ride. 

Once they get a car assigned, they will journey until the drop off, you cannot
ask them to take another car (i.e. you cannot swap them to another car to
make space for another group).

In terms of fairness of trip order: groups should be served as fast as possible,
but the arrival order should be kept when possible.
If group B arrives later than group A, it can only be served before group A
if no car can serve group A.

For example: a group of 6 is waiting for a car and there are 4 empty seats at
a car for 6; if a group of 2 requests a car you may take them in the car.
This may mean that the group of 6 waits a long time,
possibly until they become frustrated and leave.

## Evaluation rules

This challenge has a partially automated scoring system. This means that before
it is seen by the evaluators, it needs to pass a series of automated checks
and scoring.

### Checks

All checks need to pass in order for the challenge to be reviewed.

- The `acceptance` test step in the `.gitlab-ci.yml` must pass in master before you
submit your solution. We will not accept any solutions that do not pass or omit
this step. This is a public check that can be used to assert that other tests 
will run successfully on your solution. **This step needs to run without 
modification**
- _"further tests"_ will be used to prove that the solution works correctly. 
These are not visible to you as a candidate and will be run once you submit 
the solution

### Scoring

There is a number of scoring systems being run on your solution after it is 
submitted. It is ok if these do not pass, but they add information for the
reviewers.

## API

To simplify the challenge and remove language restrictions, this service must
provide a REST API which will be used to interact with it.

This API must comply with the following contract:

### GET /status

Indicate the service has started up correctly and is ready to accept requests.

Responses:

* **200 OK** When the service is ready to receive requests.

### PUT /cars

Load the list of available cars in the service and remove all previous data
(reset the application state). This method may be called more than once during
the life cycle of the service.

**Body** _required_ The list of cars to load.

**Content Type** `application/json`

Sample:

```json
[
  {
    "id": 1,
    "seats": 4
  },
  {
    "id": 2,
    "seats": 6
  }
]
```

Responses:

* **200 OK** When the list is registered correctly.
* **400 Bad Request** When there is a failure in the request format, expected
  headers, or the payload can't be unmarshalled.

### POST /journey

A group of people requests to perform a journey.

**Body** _required_ The group of people that wants to perform the journey

**Content Type** `application/json`

Sample:

```json
{
  "id": 1,
  "people": 4
}
```

Responses:

* **200 OK** or **202 Accepted** When the group is registered correctly
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshalled.

### POST /dropoff

A group of people requests to be dropped off. Whether they traveled or not.

**Body** _required_ A form with the group ID, such that `ID=X`

**Content Type** `application/x-www-form-urlencoded`

Responses:

* **200 OK** or **204 No Content** When the group is unregistered correctly.
* **404 Not Found** When the group is not to be found.
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshalled.

### POST /locate

Given a group ID such that `ID=X`, return the car the group is traveling
with, or no car if they are still waiting to be served.

**Body** _required_ A url encoded form with the group ID such that `ID=X`

**Content Type** `application/x-www-form-urlencoded`

**Accept** `application/json`

Responses:

* **200 OK** With the car as the payload when the group is assigned to a car. See below for the expected car representation 
```json
  {
    "id": 1,
    "seats": 4
  }
```

* **204 No Content** When the group is waiting to be assigned to a car.
* **404 Not Found** When the group is not to be found.
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshalled.

## Tooling

At Cabify, we use Gitlab and Gitlab CI for our backend development work. 
In this repo you may find a [.gitlab-ci.yml](./.gitlab-ci.yml) file which
contains some tooling that would simplify the setup and testing of the
deliverable. This testing can be enabled by simply uncommenting the final
acceptance stage. Note that the image build should be reproducible within
the CI environment.

Additionally, you will find a basic Dockerfile which you could use a
baseline, be sure to modify it as much as needed, but keep the exposed port
as is to simplify the testing.

:warning: Avoid dependencies and tools that would require changes to the 
`acceptance` step of [.gitlab-ci.yml](./.gitlab-ci.yml), such as 
`docker-compose`

:warning: The challenge needs to be self-contained so we can evaluate it. 
If the language you are using has limitations that block you from solving this 
challenge without using a database, please document your reasoning in the 
readme and use an embedded one such as sqlite.

You are free to use whatever programming language you deem is best to solve the
problem but please bear in mind we want to see your best!

You can ignore the Gitlab warning "Cabify Challenge has exceeded its pipeline 
minutes quota," it will not affect your test or the ability to run pipelines on
Gitlab.

## Requirements

- The service should be as efficient as possible.
  It should be able to work reasonably well with at least $`10^4`$ / $`10^5`$ cars / waiting groups.
  Explain how you did achieve this requirement.
- You are free to modify the repository as much as necessary to include or remove
  dependencies, subject to tooling limitations above.
- Document your decisions using MRs or in this very README adding sections to it,
  the same way you would be generating documentation for any other deliverable.
  We want to see how you operate in a quasi real work environment.

## Feedback

In Cabify, we really appreciate your interest and your time. We are highly 
interested on improving our Challenge and the way we evaluate our candidates. 
Hence, we would like to beg five more minutes of your time to fill the 
following survey:

- https://forms.gle/EzPeURspTCLG1q9T7

Your participation is really important. Thanks for your contribution!


