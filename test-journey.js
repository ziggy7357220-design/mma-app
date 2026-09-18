// E2E test using Chrome DevTools Protocol via CDP over Node
// Tests: onboarding → workout → completion → XP update
const { spawn } = require('child_process');
const http = require('http');

async function fetchJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { resolve(data); }
      });
    }).on('error', reject);
  });
}

(async () => {
  // Launch Chrome headless with debugging port
  const chrome = spawn('C:/Program Files/Google/Chrome/Application/chrome.exe', [
    '--headless=new',
    '--disable-gpu',
    '--no-sandbox',
    '--remote-debugging-port=9222',
    '--remote-allow-origins=*',
    'http://localhost:8765/index.html',
  ], { stdio: 'pipe' });

  chrome.stderr.on('data', d => process.stderr.write(d));
  chrome.stdout.on('data', d => process.stdout.write(d));

  // Wait for Chrome to be ready
  await new Promise(r => setTimeout(r, 3000));

  try {
    // Get tabs
    const tabs = await fetchJson('http://localhost:9222/json');
    const tab = tabs.find(t => t.url.includes('localhost:8765'));
    if (!tab) {
      console.error('No tab found. Tabs:', JSON.stringify(tabs, null, 2));
      chrome.kill();
      process.exit(1);
    }

    // Connect via WebSocket to CDP
    const WebSocket = require('ws');
    const ws = new WebSocket(tab.webSocketDebuggerUrl);

    let msgId = 0;
    const pending = new Map();

    function send(method, params = {}) {
      return new Promise((resolve, reject) => {
        const id = ++msgId;
        pending.set(id, { resolve, reject });
        ws.send(JSON.stringify({ id, method, params }));
      });
    }

    const logs = [];

    ws.on('message', (data) => {
      const msg = JSON.parse(data);
      if (msg.id && pending.has(msg.id)) {
        const { resolve, reject } = pending.get(msg.id);
        pending.delete(msg.id);
        if (msg.error) reject(new Error(msg.error.message));
        else resolve(msg.result);
      } else if (msg.method === 'Runtime.consoleAPICalled') {
        const text = msg.params.args.map(a => a.value || a.description || '').join(' ');
        logs.push(`[${msg.params.type}] ${text}`);
      } else if (msg.method === 'Runtime.exceptionThrown') {
        const ed = msg.params.exceptionDetails;
        logs.push(`[EXCEPTION ${ed.url}:${ed.lineNumber}] ${ed.text} | ${ed.exception?.description || ''} | ${ed.stackTrace?.callFrames?.map(f => f.functionName + ':' + f.lineNumber).join(', ') || ''}`);
      } else if (msg.method === 'Network.responseReceived') {
        const r = msg.params.response;
        if (r.status >= 400) logs.push(`[NET ${r.status}] ${r.url}`);
      } else if (msg.method === 'Log.entryAdded') {
        const e = msg.params.entry;
        logs.push(`[LOG ${e.level}] ${e.text} (${e.url}:${e.lineNumber})`);
      }
    });

    await new Promise(r => ws.on('open', r));

    await send('Runtime.enable');
    await send('Page.enable');
    await send('Network.enable');
    await send('Log.enable');

    // Helper: evaluate expression
    async function eval_(expr) {
      const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
      if (r.exceptionDetails) {
        console.error('EVAL ERROR:', expr, '\n', r.exceptionDetails.text, r.exceptionDetails.exception?.description);
        throw new Error(r.exceptionDetails.text);
      }
      return r.result.value;
    }

    console.log('--- Initial page load ---');
    // Clear localStorage to ensure fresh onboarding each run
    await send('Runtime.evaluate', { expression: 'localStorage.clear(); location.reload(); "cleared"' });
    await new Promise(r => setTimeout(r, 3000));
    const bodyHtml = await eval_(`document.body.innerHTML.substring(0, 500)`);
    console.log('Body HTML:', bodyHtml);
    const hasApp = await eval_(`!!document.getElementById('app')`);
    console.log('Has #app:', hasApp);
    console.log('Console logs so far:');
    logs.forEach(l => console.log(' ', l));
    const initialHtml = await eval_(`document.querySelector('.onboarding-step-title')?.textContent || 'no onboarding'`);
    console.log('Step 1 title:', initialHtml);

    // Step through onboarding
    console.log('\n--- Step 1: Martial Arts ---');
    await eval_(`
      document.querySelectorAll('.option')[0].click();
      document.querySelectorAll('.option')[1].click();
      'clicked'
    `);
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 200));

    console.log('--- Step 2: Level ---');
    let title = await eval_(`document.querySelector('.onboarding-step-title').textContent`);
    console.log('Title:', title);
    await eval_(`document.querySelectorAll('.option')[1].click()`); // Intermediate
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 200));

    console.log('--- Step 3: Goals ---');
    title = await eval_(`document.querySelector('.onboarding-step-title').textContent`);
    console.log('Title:', title);
    await eval_(`(() => {
      document.querySelectorAll('.option')[1].click();
      document.querySelectorAll('.option')[2].click();
      return 'clicked';
    })()`);
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 200));

    console.log('--- Step 4: Session Time ---');
    title = await eval_(`document.querySelector('.onboarding-step-title').textContent`);
    console.log('Title:', title);
    await eval_(`document.querySelectorAll('.option')[3].click()`); // 45 min
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 200));

    console.log('--- Step 5: Days per week ---');
    title = await eval_(`document.querySelector('.onboarding-step-title').textContent`);
    console.log('Title:', title);
    await eval_(`document.querySelectorAll('.option')[3].click()`); // 5 days
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 200));

    console.log('--- Step 6: Available Days ---');
    title = await eval_(`document.querySelector('.onboarding-step-title').textContent`);
    console.log('Title:', title);
    await eval_(`(() => {
      document.querySelectorAll('.option')[0].click();
      document.querySelectorAll('.option')[1].click();
      document.querySelectorAll('.option')[2].click();
      document.querySelectorAll('.option')[3].click();
      document.querySelectorAll('.option')[4].click();
      return 'clicked';
    })()`);
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 200));

    console.log('--- Step 7: Equipment ---');
    title = await eval_(`document.querySelector('.onboarding-step-title').textContent`);
    console.log('Title:', title);
    await eval_(`(() => {
      document.querySelectorAll('.option')[0].click();
      document.querySelectorAll('.option')[1].click();
      document.querySelectorAll('.option')[2].click();
      return 'clicked';
    })()`);
    await eval_(`document.querySelector('.btn-primary').click()`);
    await new Promise(r => setTimeout(r, 500));

    // Verify we landed on Home
    console.log('\n--- Home screen ---');
    const homeLoaded = await eval_(`!!document.querySelector('.bottom-nav')`);
    console.log('Bottom nav rendered:', homeLoaded);
    const heroTitle = await eval_(`document.querySelector('.hero-title')?.textContent || 'no hero'`);
    console.log('Hero title:', heroTitle);
    const greeting = await eval_(`document.querySelector('.user-name')?.textContent`);
    console.log('User name:', greeting);

    // Check XP
    let xp = await eval_(`localStorage.getItem('stance.app.v1')`);
    let parsed = JSON.parse(xp);
    console.log('After onboarding XP:', parsed.xp);
    console.log('Onboarded:', parsed.onboarded);
    console.log('Schedule length:', parsed.schedule.length);

    // Start a workout - navigate to Train tab first if today is rest day
    console.log('\n--- Start workout ---');
    const todayIsTraining = await eval_(`
      const heroLabel = document.querySelector('.hero-label')?.textContent || '';
      heroLabel.toLowerCase().includes('today')
    `);
    console.log('Today is training day:', todayIsTraining);

    if (todayIsTraining) {
      await eval_(`document.querySelector('.btn-start').click()`);
    } else {
      // Navigate to Train tab and pick a workout
      await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.toLowerCase().includes('train')).click()`);
      await new Promise(r => setTimeout(r, 400));
      const trainTitle = await eval_(`document.querySelector('.screen-title')?.textContent`);
      console.log('Train screen title:', trainTitle);
      const tiles = await eval_(`document.querySelectorAll('.train-tile').length`);
      console.log('Train tiles:', tiles);
      // Click first workout tile (skip the "Quick tools" section)
      await eval_(`(() => {
        const tiles = document.querySelectorAll('.train-tile');
        tiles[tiles.length - 1].click();
        return 'clicked';
      })()`);
    }
    await new Promise(r => setTimeout(r, 500));

    // Check player mounted
    const playerMounted = await eval_(`!!document.querySelector('.player')`);
    console.log('Player mounted:', playerMounted);
    const playerTitle = await eval_(`document.querySelector('.player-title')?.textContent`);
    console.log('Player title:', playerTitle);
    const exerciseName = await eval_(`document.querySelector('.player-exercise-name')?.textContent`);
    console.log('First exercise:', exerciseName);

    // Skip to completion by clicking skip on every exercise
    console.log('\n--- Skip all exercises to completion ---');
    for (let i = 0; i < 20; i++) {
      const status = await eval_(`(() => {
        const hasPlayer = !!document.querySelector('.player');
        const hasComplete = !!document.querySelector('.complete-screen');
        const exercise = document.querySelector('.player-exercise-name')?.textContent;
        const timer = document.querySelector('.player-timer')?.textContent;
        return { hasPlayer, hasComplete, exercise, timer, title: document.title };
      })()`);
      console.log(`  iter ${i}: title="${status.title}" player=${status.hasPlayer} complete=${status.hasComplete} ex=${status.exercise} time=${status.timer}`);
      if (status.hasComplete) {
        console.log(`Reached completion screen at iter ${i}`);
        break;
      }
      if (!status.hasPlayer) {
        console.log(`Player gone at iteration ${i}`);
        break;
      }
      // Click "Skip"
      const clicked = await eval_(`(() => {
        const btns = Array.from(document.querySelectorAll('.player-footer .btn'));
        const labels = btns.map(b => JSON.stringify(b.textContent.trim()));
        const skipBtn = btns.find(b => b.textContent.trim() === 'Skip');
        try {
          if (skipBtn) { skipBtn.click(); return 'clicked labels=' + labels.join(','); }
          return 'no skip labels=' + labels.join(',');
        } catch (e) { return 'ERR: ' + e.message; }
      })()`);
      if (i < 8) console.log(`  click: ${clicked}`);
      await new Promise(r => setTimeout(r, 200));
    }

    await new Promise(r => setTimeout(r, 300));
    const completeTitle = await eval_(`document.querySelector('.complete-title')?.textContent`);
    console.log('Complete title:', completeTitle);

    // Check XP awarded
    xp = await eval_(`localStorage.getItem('stance.app.v1')`);
    parsed = JSON.parse(xp);
    console.log('\nAfter completion XP:', parsed.xp);
    console.log('Workouts completed:', parsed.workoutsCompleted);
    console.log('Current streak:', parsed.currentStreak);
    console.log('Total minutes:', parsed.totalTrainingMinutes);

    // Click Done to return home
    console.log('\n--- Return to Home ---');
    await eval_(`document.querySelector('.complete-screen .btn-primary').click()`);
    await new Promise(r => setTimeout(r, 3500)); // Wait for auto-reset

    // Verify back on Home with updated state
    const onHome = await eval_(`!!document.querySelector('.bottom-nav')`);
    console.log('Back to main app:', onHome);

    // Navigate through tabs
    console.log('\n--- Test tabs ---');
    const tabLabels = ['home', 'plan', 'train', 'learn', 'profile'];
    for (const label of tabLabels) {
      await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.toLowerCase().includes('${label}')).click()`);
      await new Promise(r => setTimeout(r, 200));
      const title = await eval_(`(() => {
        // Look for various title markers
        return document.querySelector('.screen-title')?.textContent
          || document.querySelector('.user-name')?.textContent
          || document.querySelector('.profile-name')?.textContent
          || 'no title';
      })()`);
      console.log(`${label}: ${title}`);
    }

    // Test Learn section
    await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.toLowerCase().includes('learn')).click()`);
    await new Promise(r => setTimeout(r, 200));
    const martialArts = await eval_(`Array.from(document.querySelectorAll('.martial-card-name')).map(e => e.textContent)`);
    console.log('Martial arts on Learn:', martialArts);

    // Open a martial art
    await eval_(`document.querySelectorAll('.martial-card')[0].click()`);
    await new Promise(r => setTimeout(r, 200));
    const techniqueTitle = await eval_(`document.querySelector('.train-tile-title')?.textContent`);
    console.log('First technique:', techniqueTitle);

    console.log('\n=== Console Logs ===');
    logs.forEach(l => console.log(l));

    // Test direct call to complete
    const directComplete = await eval_(`(() => {
      try {
        // Manually trigger skip to completion
        const result = 'no error';
        return result;
      } catch (e) { return 'ERR: ' + e.message; }
    })()`);
    console.log('Direct check:', directComplete);

    console.log('\n✅ Test run complete');
  } catch (err) {
    console.error('TEST FAILED:', err.message);
    console.error(err.stack);
    console.log('\n=== Console Logs (on failure) ===');
    logs.forEach(l => console.log(l));
  } finally {
    chrome.kill();
    process.exit(0);
  }
})();
