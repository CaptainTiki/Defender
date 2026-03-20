# 🚧 Defender v0.3 – Priority List

## 🎯 Goal
Shift from "working prototype" → **tight, high-pressure incremental loop**

Core loop target:
> Struggle → scrape a kill → grab bits under pressure → die → upgrade → repeat

---

## 🔥 Core Tuning (Do These First)

### 1. Lower Player Fire Rate
- Target: ~1 shot every 1.5–2 seconds
- Shots should feel **deliberate**
- Missing should matter

---

### 2. Increase Player Damage
- Target: 4–5 hits to kill first enemy
- Each hit should feel impactful
- Avoid:
  - 1–2 shot kills (no tension)
  - 10+ shots (too slow / boring)

---

### 3. Aggressively Ramp Spawn Pressure
- After first kill, player should feel **immediate danger**
- No downtime to safely collect bits
- Enemies should already be closing in

---

### 4. Make Early Upgrades Cheap + Strong
- First upgrades cost: **1–2 bits**
- Effects should be noticeable:
  - +25% fire rate
  - +25–40% damage
  - +1 projectile (optional)
- Player should feel stronger **next run immediately**

---

## ⚠️ Critical Systems

### 5. Add Player Damage + Hit Feedback
- Implement:
  - Health system
  - Flash on hit
  - Knockback or shove
  - Camera nudge
  - UI pulse
- Goal:
  - Getting hit feels **bad immediately**
  - Death feels understandable

---

### 6. Add Spawn Grace Window (Short)
- Enemies pause ~0.2s after spawning
- BUT spawn close enough to still be dangerous
- Improves:
  - Readability
  - Fairness

---

## ⚔️ Combat Feel & Pressure

### 7. Reduce Enemy Health, Increase Count
- Enemies die in ~4–5 hits
- Increase enemy density instead of HP
- Goal:
  - Satisfying kills
  - Overwhelming pressure

---

### 8. Increase Enemy Approach Speed
- Enemies should engage within **3–5 seconds**
- No slow “walk-in” time
- Pressure should build quickly

---

### 9. Add a “Panic Button” Ability
Examples:
- Dash
- Pushback pulse
- Small AoE blast
- Temporary invulnerability

Requirements:
- Limited use / cooldown
- Not spammable

Goal:
- Give player a **single recovery tool**
- Death feels like a mistake, not unfair

---

## 📈 System Direction

### 10. Replace Fixed Waves with Pressure Scaling (Internally)
- Increase spawn rate over time
- Introduce enemy types gradually
- Treat waves as presentation, not logic

Goal:
> Player loses control due to pressure, not a timer

---

## 🎯 Optional (High Impact)

### 11. Add One Alternate Weapon
Pick one:
- Shotgun
- Beam
- Explosive shot

Goal:
- Test combat depth
- Introduce positioning decisions
- Improve replay feel

---

## 🧪 Playtest Targets

### Early Game Feel
- First enemy appears: **1–2 seconds**
- First engagement: **3–5 seconds**
- First kill: **5–10 seconds**
- Overwhelm begins: **15–20 seconds**
- Likely death: **25–40 seconds**

---

### Expected Progression Loop

#### Run 1
- Kill 1–2 enemies
- Earn ~3–5 bits
- Die quickly
- Buy first upgrade

#### Run 2
- Kill 2–3 enemies
- Survive slightly longer
- Feel upgrade impact

#### Run 3–5
- Break first difficulty wall
- Quickly hit next wall

---

## 🚀 Success Criteria

You know v0.3 is working when:
- Player feels pressure quickly
- Death feels fair and expected
- Upgrades have immediate impact
- Player thinks:
  > “I can do better next run”

---

## 💣 Top 3 Priorities (If Time Limited)

1. Add player damage + hit feedback  
2. Aggressively ramp spawn pressure  
3. Make early upgrades strong + cheap  

---

## 🧠 Guiding Principle

> The game should feel slightly unfair—but immediately rewarding to improve.

Avoid:
- Long safe runs
- Weak upgrades
- Slow pressure ramp

Embrace:
- Fast failure
- Quick upgrades
- Immediate tension