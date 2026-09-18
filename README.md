# Stance — Martial Arts Training

A personal martial arts training system. Built as a clean, dark, mobile-first web app.

## Run it

```bash
cd "mma app"
python -m http.server 8765
```

Open <http://localhost:8765>.

## Stack

- Vanilla JavaScript (ES modules)
- Plain CSS (dark theme, no framework)
- localStorage for persistence
- Zero build step

## Structure

```
index.html
styles.css
js/
  main.js              App shell + routing + nav
  state.js             Reactive store (localStorage)
  ui.js                DOM helpers, icons, toasts
  onboarding.js        7-step onboarding
  player.js            Workout player + Round timer
  combo.js             Combo creator
  data/
    content.js         Martial arts, techniques, exercises, workouts, achievements
    plan.js            Personalization engine (rule-based weekly plan generator)
  screens/
    home.js            Today's training, streak, XP
    plan.js            Weekly schedule, reschedule
    train.js           All workouts, timer, combo creator
    learn.js           Martial arts library → techniques
    profile.js         Stats, XP, streak, achievements, settings
```

## Features (Phase 1 MVP)

- 7-step onboarding (martial arts, level, goals, duration, days, equipment)
- Rule-based weekly plan generation
- Workout player with sequential exercise timer
- Round timer with configurable rounds/rest
- Combo creator
- Learn section with technique library (steps, mistakes, mark as learned)
- XP, level, streak tracking
- Achievements
- Skill progress bars (separate from XP)
- Reschedule missed sessions

## Tests

- `node test-journey.js` — full user flow (onboarding → workout → completion → XP)
- `node test-flows.js` — learn, combo, timer, profile, plan
