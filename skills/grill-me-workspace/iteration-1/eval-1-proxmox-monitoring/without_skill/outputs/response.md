# Baseline Response (No Skill)

**Prompt:** "grill me on my plan to set up a centralized monitoring stack on Proxmox. I'm thinking I'll spin up a new LXC container and throw Grafana, Prometheus, and alerting on it. Also want it to watch the VMs and the network gear."

---

Alright, let's get into it.

**On the LXC choice:**
Why LXC over a VM? Monitoring stacks — especially Prometheus with long retention — can get storage-hungry. LXC is fine, but are you giving it dedicated storage or sharing the Proxmox storage pool? If the container dies and takes your metrics with it, you've lost visibility at exactly the wrong time.

**On co-locating everything:**
Grafana, Prometheus, and alerting all in one container. What's your HA story if that container goes down? If the thing you're using to monitor your infrastructure is on the same infrastructure with no redundancy, you've got a blind spot during the exact failure you'd want to know about. Have you thought about running alerting separately, or at minimum exporting alerts to something outside the cluster (PagerDuty, ntfy, email)?

**On what "watch the VMs" means:**
Are you planning to run `node_exporter` on each VM, or use Proxmox's built-in metrics endpoint? The built-in Proxmox exporter gives you hypervisor-level stats (CPU, RAM, disk I/O per VM) without touching the VMs themselves. But if you want inside-the-OS metrics, you need node_exporter on each one. Which do you actually need?

**On the network gear:**
What gear are we talking — UniFi? Something else? UniFi doesn't expose a native Prometheus endpoint. You'd need either the Unifi Poller exporter or SNMP. Have you accounted for that complexity? And do you have credentials/API access sorted for it?

**On alerting specifically:**
What are you using for the alert delivery layer — Alertmanager? And where are alerts going? If it's just email, what happens when email is down? If it's a webhook to something like ntfy or Slack, is that service outside the monitored environment?

**On retention and sizing:**
How long do you want to retain metrics? Prometheus default is 15 days. If you want longer, you're either configuring a longer retention window (storage implications) or setting up remote write to something like Thanos or a long-term storage backend. Have you scoped storage for this?

**On bootstrapping order:**
If this container is also watching itself, what monitors the monitor? Prometheus has no external heartbeat unless you wire one up. Worth having at least a dead man's switch — something that alerts you if metrics *stop* coming in, not just when something goes wrong.

What's your answer on the HA question — that's the one I'd push hardest on first.
