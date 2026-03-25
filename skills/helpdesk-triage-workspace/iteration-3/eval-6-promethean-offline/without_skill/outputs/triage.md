# Helpdesk Triage — Promethean Board No Internet

**Ticket Date:** 2026-03-17
**Submitter:** Michael Torres (mtorres@germanschool-mn.org)
**Location:** Room 214, GIS (Twin Cities German Immersion School)
**Device:** Promethean ActivPanel (model unknown)

---

## Triage Table

| Field | Value |
|---|---|
| Ticket | eval-6-promethean-offline |
| Submitter | Michael Torres (mtorres@germanschool-mn.org) |
| Location | Room 214, GIS |
| Device | Promethean ActivPanel (board model unknown) |
| Symptom | Internet light off, lessons not loading |
| Self-troubleshooting done | Power cycled via remote |
| Priority | Medium |
| Category | AV / Interactive Display |
| Assigned to | GIS Helpdesk (L1) |

---

## Diagnosis

**Most likely cause: Network connectivity loss at the board level**

The internet indicator light being off on a Promethean board means the board is not receiving a network signal — this is a network-layer issue, not a software or display issue. Soft power cycle via remote did not resolve it, which rules out a transient software hang but does not rule out a DHCP/network registration failure.

**Differential:**

| Hypothesis | Likelihood | Notes |
|---|---|---|
| Ethernet cable unplugged or loose at board or wall | High | Most common physical cause in classroom settings |
| Switch port down or cable damaged | Medium | Check managed switch if ethernet-connected |
| Board on Wi-Fi and AP unreachable or credential expired | Medium | Promethean boards can use Wi-Fi; worth verifying connection mode |
| Board did not obtain IP via DHCP after reboot | Medium | Soft remote power cycle may not fully reinitialize network stack |
| Board network adapter failed | Low | Hardware failure, less common |
| Captive portal / 802.1X auth issue | Low | Less common in K-12 LAN setups but possible |

**Recommended steps (in order):**

1. Physically inspect the ethernet cable at the back of the board and the wall jack — reseat both ends.
2. Check the switch port indicator for Room 214 (if managed switch is accessible via UniFi).
3. If Wi-Fi: go to Settings > Network on the board and verify Wi-Fi is connected and shows an IP.
4. Perform a full hard power cycle: use the physical power button on the board (not the remote), wait 30 seconds, power back on.
5. If still no IP: check the board's network settings for a static IP conflict or misconfiguration.
6. Escalate to network/infrastructure if switch port is confirmed down or cable run is suspected bad.

---

## Internal Note

**For ticket system / technician:**

Michael Torres, Room 214 — Promethean board showing no internet connectivity (indicator light off). Soft power cycle via remote did not resolve. Needs a physical visit to:

- Check/reseat ethernet cable at board and wall jack
- Verify switch port status for Room 214 in UniFi
- If Wi-Fi board: confirm wireless network association and IP assignment
- Hard power cycle if cable is confirmed connected but light still off

This is likely a loose cable or failed network re-initialization after reboot. If switch port is down, escalate to network admin. Board model unknown — verify on-site and log in asset inventory if not already recorded.

**Active classroom impact** — recommend tech visit before end of school day.
