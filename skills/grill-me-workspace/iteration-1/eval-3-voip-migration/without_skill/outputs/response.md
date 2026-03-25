# Stress Test: GIS Phone Migration to SpectrumVOIP

The plan is directionally fine but it's missing several steps that will cause pain if skipped.

---

## What's actually missing

**Number porting is the dangerous part.** "Port the numbers" sounds simple but porting from Spectrum Business to SpectrumVOIP is still a carrier-to-carrier port — even if it's the same parent company, the billing entities are different and the LOA/porting process is the same. Port windows are typically 7-21 business days, and if the new account isn't fully provisioned before the port completes, calls drop into a void. You need a firm port date and a rollback plan.

**What happens to service during cutover?** The plan jumps from "port the numbers" to "swap hardware" with no mention of a parallel-run period. Best practice is to run the new system in parallel — new DIDs on SpectrumVOIP while old lines stay active — until you're confident, then port the main numbers. Doing a hard cutover with porting and hardware swap simultaneously means if anything goes wrong, the school has no phones.

**Hardware compatibility is not guaranteed.** "Swap the hardware" — swap to what? SpectrumVOIP typically requires their certified handsets or ATAs. If GIS currently has phones provisioned by Spectrum Business, they may not re-provision on SpectrumVOIP's platform. You could be looking at full handset replacement, which affects cost and timeline.

**Who owns the admin console?** Spectrum Business likely has all call routing, hunt groups, voicemail, auto-attendant configured on their side. SpectrumVOIP will be a blank slate. Someone has to document the current call flow and rebuild it. This is not a "done" step — it can easily take a day or more depending on how complex GIS's phone tree is.

**Voicemail migration.** Any saved voicemails on the old system will be lost unless you export them before porting. If staff rely on saved voicemails (HR, admin, front office), this matters.

**E911 registration.** New VoIP service = new E911 registration required per line. If any lines are associated with the wrong address or not registered at all, you have a compliance/liability issue for a school.

**Contract timing.** If the current Spectrum contract has an ETF, the savings calculation changes. Have you confirmed there's no early termination penalty?

---

## The actual risk profile

Low risk: The decision itself — same provider family, cheaper, numbers port over.

Medium risk: Hardware swap — could be a $0 swap or a $5-10k handset replacement depending on what's currently installed.

High risk: Cutover day — if porting and hardware swap happen at the same time without a tested rollback, and something goes wrong, GIS is a school with no working phones. That's a real problem during school hours.

---

## Recommended additions to the plan

1. Audit current hardware against SpectrumVOIP's certified device list before signing
2. Document current call routing (auto-attendant, hunt groups, extensions, voicemail)
3. Schedule port during non-school hours or school break
4. Set up and test new system on temp DIDs before porting main numbers
5. Confirm ETF status on Spectrum Business contract
6. Register E911 on all lines before go-live
7. Export/save any voicemails staff need to keep
8. Have Spectrum Business account active until port is confirmed complete

The plan isn't wrong — it's just compressed. The four bullets are phase headings, not the actual steps.
