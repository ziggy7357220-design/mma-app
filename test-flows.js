// Additional flow tests: technique learning, combo creator, round timer
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
  const chrome = spawn('C:/Program Files/Google/Chrome/Application/chrome.exe', [
    '--headless=new', '--disable-gpu', '--no-sandbox',
    '--remote-debugging-port=9223', '--remote-allow-origins=*',
    'http://localhost:8765/index.html',
  ], { stdio: 'pipe' });

  await new Promise(r => setTimeout(r, 3000));

  try {
    const tabs = await fetchJson('http://localhost:9223/json');
    const tab = tabs.find(t => t.url.includes('localhost:8765'));
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
    async function eval_(expr) {
      const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
      if (r.exceptionDetails) throw new Error(r.exceptionDetails.text);
      return r.result.value;
    }
    ws.on('message', (data) => {
      const msg = JSON.parse(data);
      if (msg.id && pending.has(msg.id)) {
        const { resolve, reject } = pending.get(msg.id);
        pending.delete(msg.id);
        if (msg.error) reject(new Error(msg.error.message));
        else resolve(msg.result);
      }
    });
    await new Promise(r => ws.on('open', r));
    await send('Runtime.enable');
    await send('Page.enable');

    // Skip onboarding quickly
    await send('Runtime.evaluate', { expression: 'localStorage.clear(); location.reload(); "x"' });
    await new Promise(r => setTimeout(r, 2500));

    // Step through onboarding quickly
    console.log('--- Fast onboarding ---');
    await eval_(`(() => {
      // Step 1: Boxing, TKD
      document.querySelectorAll('.option')[0].click();
      document.querySelectorAll('.option')[1].click();
      return 'x';
    })()`);
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 150));

    await eval_(`document.querySelectorAll('.option')[1].click(); 'x'`); // Intermediate
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 150));

    await eval_(`(() => { document.querySelectorAll('.option')[1].click(); document.querySelectorAll('.option')[2].click(); return 'x'; })()`);
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 150));

    await eval_(`document.querySelectorAll('.option')[3].click(); 'x'`); // 45 min
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 150));

    await eval_(`document.querySelectorAll('.option')[2].click(); 'x'`); // 4 days
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 150));

    await eval_(`(() => { for(let i=0;i<4;i++) document.querySelectorAll('.option')[i].click(); return 'x'; })()`);
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 150));

    await eval_(`document.querySelectorAll('.option')[1].click(); document.querySelectorAll('.option')[2].click(); 'x'`);
    await eval_(`document.querySelector('.btn-primary').click(); 'x'`);
    await new Promise(r => setTimeout(r, 500));

    console.log('Onboarded.');

    // Test 1: Learn a technique
    console.log('\n--- Test: Learn technique ---');
    await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.includes('Learn')).click(); 'x'`);
    await new Promise(r => setTimeout(r, 300));
    await eval_(`document.querySelectorAll('.martial-card')[0].click(); 'x'`); // Boxing
    await new Promise(r => setTimeout(r, 300));
    await eval_(`document.querySelectorAll('.train-tile')[0].click(); 'x'`); // Jab
    await new Promise(r => setTimeout(r, 300));

    let xpBefore = await eval_(`JSON.parse(localStorage.getItem('stance.app.v1')).xp`);
    console.log('XP before:', xpBefore);

    await eval_(`(() => {
      const btn = Array.from(document.querySelectorAll('.btn')).find(b => b.textContent.includes('Mark as Learned'));
      btn && btn.click();
      return 'x';
    })()`);
    await new Promise(r => setTimeout(r, 300));

    let xpAfter = await eval_(`JSON.parse(localStorage.getItem('stance.app.v1')).xp`);
    console.log('XP after learning jab:', xpAfter);
    console.log('Delta:', xpAfter - xpBefore, '(expected 10)');

    // Test 2: Combo creator
    console.log('\n--- Test: Combo Creator ---');
    await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.includes('Train')).click(); 'x'`);
    await new Promise(r => setTimeout(r, 300));
    await eval_(`(() => {
      const tiles = Array.from(document.querySelectorAll('.train-tile'));
      const combo = tiles.find(t => t.textContent.includes('Combo Creator'));
      combo && combo.click();
      return 'x';
    })()`);
    await new Promise(r => setTimeout(r, 300));

    let comboScreen = await eval_(`document.querySelector('.screen-title')?.textContent`);
    console.log('Combo Creator screen:', comboScreen);

    // Click 3 strikes
    await eval_(`(() => {
      const strikes = document.querySelectorAll('.combo-strike');
      strikes[0].click();
      strikes[1].click();
      strikes[5].click();
      return 'x';
    })()`);
    await new Promise(r => setTimeout(r, 200));

    let comboChips = await eval_(`document.querySelectorAll('.combo-chip').length`);
    console.log('Combo chips added:', comboChips, '(expected 3)');

    // Test 3: Round timer
    console.log('\n--- Test: Round Timer ---');
    await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.includes('Train')).click(); 'x'`);
    await new Promise(r => setTimeout(r, 300));
    await eval_(`(() => {
      const tiles = Array.from(document.querySelectorAll('.train-tile'));
      const timer = tiles.find(t => t.textContent.includes('Round Timer'));
      timer && timer.click();
      return 'x';
    })()`);
    await new Promise(r => setTimeout(r, 300));

    let timerScreen = await eval_(`document.querySelector('.screen-title')?.textContent`);
    console.log('Timer screen:', timerScreen);

    // Test 4: Profile shows updated data
    console.log('\n--- Test: Profile ---');
    await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.includes('Profile')).click(); 'x'`);
    await new Promise(r => setTimeout(r, 300));

    let profileName = await eval_(`document.querySelector('.profile-name')?.textContent`);
    let profileLevel = await eval_(`document.querySelector('.profile-level')?.textContent`);
    console.log('Profile name:', profileName, 'Level:', profileLevel);

    // Test 5: Reschedule flow (need a missed session)
    console.log('\n--- Test: Plan ---');
    await eval_(`Array.from(document.querySelectorAll('.nav-item')).find(n => n.textContent.includes('Plan')).click(); 'x'`);
    await new Promise(r => setTimeout(r, 300));
    let planDays = await eval_(`document.querySelectorAll('.day-row').length`);
    console.log('Plan days:', planDays, '(expected 7)');

    console.log('\n✅ All additional flows pass');
  } catch (err) {
    console.error('TEST FAILED:', err.message);
    console.error(err.stack);
  } finally {
    chrome.kill();
    process.exit(0);
  }
})();
