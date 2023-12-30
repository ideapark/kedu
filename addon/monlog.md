# Monitoring and Logging

- What is the difference between logging and monitoring.

Though closely related, they are actually quite different and are used
for different problems and often stored in different infrastructure.

Logging records events (e.g., a Pod being created or an API call
failing), and monitoring records statistics (e.g., the latency of a
particular request, the CPU used by a process, or the number of
requests to a particular endpoint). Logged records, by their nature,
are discrete, whereas monitoring data is a sampling of some continuous
value.

Logging systems are generally used to search for relevant
information. (“Why did creating that Pod fail?” “Why didn’t that
Service work correctly?”)  For this reason, log storage systems are
oriented around storing and querying vast quantities of data, whereas
monitoring systems are generally geared around visualization.  (“Show
me the CPU usage over the last hour.”)  Thus, they are stored in
systems that can efficiently store time-series data.

It is worth nothing that neither logging nor monitoring alone are
sufficient to understand your cluster. Monitoring data can give you a
good sense of the overall health of your cluster and can help you
identify anomalous events that maybe occuring. Logging, on the other
hand, is critical for diving in and understanding what is
actually happening, possibly across many machines, to cause such
anomalous behavior.

- What does it mean when talking about computer system monitoring

## Alerting

Knowing when things are going wrong is usually the most important
thing that you want monitoring for. You want the monitoring system to
call in a human to take a look.

## Debugging

Now that you have called in a human, they need to investigate to
determine the root cause and ultimately resolve whatever the issue is.

## Trending

Alerting and debugging usually happen on time scales on the order of
minutes to hours. While less urgent, the ability to see how your
systems are being used and changing over time is also useful.
Trending can feed into design decisions and processes such as capacity
planning.

## Plumbing

When all you have is a hammer, everything starts to look like a
nail. At the end of the day all monitoring systems are data processing
pipelines. Sometimes it is more convenient to appropriate part of your
monitoring system for another purpose, rather than building a bespoke
solution. This is not strictly monitoring, but it is common in
practice.

- Categories of monitoring

Most monitoring is about *events*. All events have context, having all
the context for all the events would be great for debugging and
understanding how your systems are performing in both technical and
business terms, but that amount of data is not practical to process
and store. Thus there are what I would see as roughly four ways to
approach reducing that volume of data to something workable, namely
*profiling*, *tracing*, *logging*, and *metrics*.

## Profiling

Profiling takes the approach that you can’t have all the context for
all of the events all of the time, but you can have some of the
context for limited periods of time.

## Tracing

Tracing doesn’t look at all events, rather it takes some proportion of
events such as one in a hundred that pass through some functions of
interest. Tracing will note the functions in the stack trace of the
points of interest, and often also how long each of these functions
took to execute. From this you can get an idea of where your program
is spending time and which code paths are most contributing to
latency.

## Logging

Logging looks at a limited set of events and records some of the
context for each of these events. For example, it may look at all
incoming HTTP requests, or all outgoing database calls.  To avoid
consuming too much resources, as a rule of thumb you are limited to
somewhere around a hundred fields per log entry. Beyond that,
bandwidth and storage space tend to become a concern.

## Metrics

Metrics largely ignore context, instead tracking aggregations over
time of different types of events. To keep resource usage sane, the
amount of different numbers being tracked needs to be limited: ten
thousand per process is a reasonable upper bound for you to keep in
mind.

In one word, e,g. metrics describes that there were 15 requests in the
last minute that took 4 seconds to handle, resulted in 40 database
calls, 17 cache hits, and 2 purchases by customers.  The cost and code
paths of the individual calls would be the concern of profiling or
logging.
