# Nedo-Drosera-Starter 🌿  
_On-chain defense for the worst-case scenario: compromised keys._  

---

## ⚠️ Disclaimer  
This repository contains **proof-of-concept (PoC) traps** I built using the [Drosera framework](https://dev.drosera.io).  
They are **not audited** and **not production-ready**.  
Protocols and developers can deploy them on testnets to explore their use cases and extend them for real defense.  

---
---


## 🚨 The Problem  

Audits secure the code — **not the keys**.  
Today’s biggest DeFi exploits don’t usually stem from reentrancy or math bugs. They come from:  

- **Private key compromise** — phishing, malware, poor OPSEC  
- **Insider threats** — engineers or multisig signers going rogue  
- **Social engineering / coercion** — trusted signers forced to act maliciously  

These risks are **not auditable**. No static analysis or fuzzing tool can anticipate human failure or betrayal. Yet when they strike, a protocol’s entire treasury can be gone in minutes.  

---

## 🛡️ The PoC Solution  

Drosera adds an **on-chain defensive layer** for the worst case.  

- **Traps** — lightweight contracts that monitor high-risk actions (mint spikes, ownership transfers, draining behavior).  
- **Automated responses** — triggered traps can pause, freeze, or escalate to DAO governance.  
- **Programmable defense** — projects select traps and reactions that fit their threat model.  

Instead of relying solely on key security, Drosera ensures that even if keys are compromised, your protocol still has a fighting chance. 
This repo showcases **PoC traps** that demonstrate the model.  

---

## 🎯 Threat Model  

**Assumptions**  
- Attacker has **one compromised hot key** (admin or engineer).  
- They can:  
  - Transfer ownership  
  - Call `mint()`, `rescue()`, `transfer()`  
  - Change whitelists or allowances  
- They may use mempool, private bundles (Flashbots), or multi-step atomic txs.  
- They can deploy fresh EOAs, contracts, or use bridges/mixers.  

**Attack Surface**  
- Admin/minter roles on tokens, vesting contracts, or bridges  
- DAO-owned LP tokens or treasury holdings (ETH, USDC, etc.)  
- Approvals from vesting/treasury to routers/bridges  

**Defensive Goals**  
- **Limit blast radius** — a single key can’t drain everything instantly  
- **Detect anomalies** — flag risky ownership changes, mint spikes, vesting drains, or approvals  
- **Respond atomically** — mitigation within the **same block** via Drosera Responder + Flashbots  

---

## ⚙️ Architecture  

Drosera has two main components: **Traps** and the **Responder**.  

### 🔒 Traps  
Smart contracts that **observe and constrain** high-risk behaviors.  

## 🧩 Available PoC Traps (Custom-Built Here)

This repo contains Proof of Concept traps I designed and implemented using the Drosera framework.  

- **OwnerChangeTrap** → detects and flags sudden ownership transfers.  
- **MintSpikeTrap** → monitors anomalous token minting events.  
- **VestingDrainTrap** → watches vesting contracts for drain-like patterns.  
- **ApprovalSpikeTrap** → alerts on suspicious allowance spikes.  
- **FreshRecipientTrap** → prevents large transfers to brand-new EOAs.  
- **LPReserveTrap** → protects DAO LP reserves from sudden drains.  

Each trap is modular — protocols can opt into only the defenses that fit their threat model.  


### ⚡ Responder  
When a trap is triggered, the **Drosera Responder** can:  
- **Pause** — freeze contracts to stop further damage  
- **Sweep** — move DAO assets (treasury, LPs) to a safe vault  
- **Escalate** — hand off to governance for bigger decisions  

The responder is built for **atomic action**: paired with Flashbots, mitigations can land in the **same block** as the exploit attempt, cutting off escape routes.  

---

