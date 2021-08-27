# Endpoints

# EndpointSlice

*EndpointSlices* provide a more scalable and extensible way to track
network endpoints.

Since all the network endpoints for a service were stored in a single
Endpoints resource, those resources could get quite large. That
affected the performance of Kubernetes components (notably the control
plane) and resulted in significant amounts of network traffic and
processing when Endpoints changed. EndpointSlices help you mitigate
those issues as well as provide an extensible platform for additional
features such as topological routing.
