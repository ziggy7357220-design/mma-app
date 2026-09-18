const fs = require('fs');
const content = fs.readFileSync('stance_app/lib/data/content.dart', 'utf8');

function verify() {
    const results = {
        duplicates: [],
        timingErrors: [],
        crossContamination: [],
        totalWorkouts: 0,
        artCounts: {}
    };

    const workoutBlocks = content.split('Workout(').slice(1);
    results.totalWorkouts = workoutBlocks.length;

    workoutBlocks.forEach(block => {
        const matchId = block.match(/id:\s*\'([^\']+)\'/);
        const matchArt = block.match(/martialArt:\s*\'([^\']+)\'/);
        const matchDuration = block.match(/duration:\s*(\d+),/);

        if (!matchId || !matchArt || !matchDuration) return;

        const id = matchId[1];
        const art = matchArt[1];
        const durationMin = parseInt(matchDuration[1]);

        results.artCounts[art] = (results.artCounts[art] || 0) + 1;

        const exerciseSection = block.substring(block.indexOf('exercises:'));
        const exerciseDurations = exerciseSection.match(/duration:\s*(\d+)/g) || [];
        let totalSecs = 0;
        exerciseDurations.forEach(d => {
            const sec = parseInt(d.match(/\d+/)[0]);
            totalSecs += sec;
        });

        const diff = Math.abs(totalSecs - (durationMin * 60));
        if (diff > 30) {
            results.timingErrors.push(`${id}: Declared ${durationMin}m (${durationMin * 60}s), Actual ${totalSecs}s (Diff: ${diff}s)`);
        }

        const arts = ['boxing', 'muay_thai', 'taekwondo', 'bjj', 'wrestling', 'strength'];
        arts.forEach(otherArt => {
            if (otherArt !== art && block.includes(`'${otherArt}'`)) {
                results.crossContamination.push(`${id} contains reference to ${otherArt}`);
            }
        });
    });

    console.log('Art Counts:', results.artCounts);
    console.log('Total Workouts:', results.totalWorkouts);
    console.log('Timing Errors:', results.timingErrors);
    console.log('Cross Contamination:', results.crossContamination);
}

verify();
