const fs = require('fs');
const content = fs.readFileSync('stance_app/lib/data/content.dart', 'utf8');

function audit() {
    const results = {
        workoutInventory: [],
        timingTable: [],
        structuralIssues: {
            duplicateIds: [],
            orphanedFragments: 0,
            malformedConstructors: [],
            exercisePStep: 0,
            crossContamination: [],
            missingExpectedIds: [],
            unexpectedIds: []
        },
        constants: {
            martialArts: [],
            achievements: [],
            strikes: [],
            levels: [],
            goals: [],
            durations: [],
            daysPerWeek: [],
            weekdays: [],
            equipment: []
        }
    };

    const workoutBlocks = content.split('Workout(').slice(1);
    const seenIds = new Set();
    const workoutIds = [];

    workoutBlocks.forEach((block, index) => {
        const matchId = block.match(/id:\s*\'([^\']+)\'/);
        const matchArt = block.match(/martialArt:\s*\'([^\']+)\'/);
        const matchCat = block.match(/category:\s*\'([^\']+)\'/);
        const matchDiff = block.match(/difficulty:\s*\'([^\']+)\'/);
        const matchDuration = block.match(/duration:\s*(\d+),/);

        if (!matchId) {
            results.structuralIssues.malformedConstructors.push(`Block ${index + 1}: Missing ID`);
            return;
        }

        const id = matchId[1];
        const art = matchArt ? matchArt[1] : 'unknown';
        const cat = matchCat ? matchCat[1] : 'unknown';
        const diff = matchDiff ? matchDiff[1] : 'unknown';
        const declaredMin = matchDuration ? parseInt(matchDuration[1]) : 0;

        if (seenIds.has(id)) {
            results.structuralIssues.duplicateIds.push(id);
        }
        seenIds.add(id);
        workoutIds.push(id);

        // Timing Calculation
        const exerciseSection = block.substring(block.indexOf('exercises:'));
        const exerciseDurations = exerciseSection.match(/duration:\s*(\d+)/g) || [];
        let actualSecs = 0;
        exerciseDurations.forEach(d => {
            actualSecs += parseInt(d.match(/\d+/)[0]);
        });

        const difference = actualSecs - (declaredMin * 60);
        const pass = Math.abs(difference) <= 30;

        results.workoutInventory.push({
            id, art, cat, diff, declaredMin
        });

        results.timingTable.push({
            id,
            declaredMin,
            actualSecs,
            difference,
            status: pass ? 'PASS' : 'FAIL'
        });

        // Cross-art contamination
        const arts = ['boxing', 'muay_thai', 'taekwondo', 'bjj', 'wrestling', 'strength'];
        arts.forEach(otherArt => {
            if (otherArt !== art && block.includes(`'${otherArt}'`)) {
                results.structuralIssues.crossContamination.push(`${id} references ${otherArt}`);
            }
        });
    });

    // Other Structural Checks
    if (content.includes('ExercisePStep')) {
        results.structuralIssues.exercisePStep = (content.match(/ExercisePStep/g) || []).length;
    }

    // Constants extraction
    const extractList = (regex) => {
        const matches = [];
        let m;
        while ((m = regex.exec(content)) !== null) {
            matches.push(m[1]);
        }
        return matches;
    };

    results.constants.martialArts = extractList(/MartialArt\(id:\s*\'([^\']+)\'/g);
    results.constants.achievements = extractList(/Achievement\(id:\s*\'([^\']+)\'/g);

    // Simple count for the others to avoid massive output but ensure presence
    results.constants.strikes = (content.match(/'[A-Z][^']+'(?=,?\s*\])/g) || []).length; // approximation

    console.log(JSON.stringify(results, null, 2));
}

audit();
