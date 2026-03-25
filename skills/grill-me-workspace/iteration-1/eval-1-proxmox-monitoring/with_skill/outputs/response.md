Before we get into the stack details — why a single LXC for all of this?

Grafana, Prometheus, and alertmanager together aren't trivial under load, especially if you're scraping a bunch of targets. What's your plan if the LXC itself goes down — you lose visibility into the thing that tells you things are down. Have you thought about where this lives relative to your most critical VMs, and whether a single container is the right blast radius for your entire monitoring plane?
