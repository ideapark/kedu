# Monitoring and Logging

- What is the difference between logging and monitoring.

Though closely related, theyare actually quite different and are used
for different problems and often stored indifferent infrastructure.

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
