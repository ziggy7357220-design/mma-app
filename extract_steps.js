const fs = require('fs');

const content = fs.readFileSync('stance_app/lib/data/content.dart', 'utf8');
const workoutStart = content.indexOf('static final List<Workout> workouts = [');
if (workoutStart === -1) {
    console.log('Workouts list not found');
    process.exit(1);
}

const workoutsText = content.substring(workoutStart);
const stepRegex = /ExerciseStep\((.*?)\),/gs;
let match;
const steps = [];

while ((match = stepRegex.exec(workoutsText)) !== null) {
    const stepContent = match[1];
    const nameMatch = stepContent.match(/name:\s*['"](.*?)['"]/);
    const durMatch = stepContent.match(/duration:\s*(\d+)/);
    const drillMatch = stepContent.match(/drillId:\s*['"](.*?)['"]/);
    
    steps.push({
        name: nameMatch ? nameMatch[1] : 'Unknown',
        duration: durMatch ? parseInt(durMatch[1]) : 0,
        drillId: drillMatch ? drillMatch[1] : 'None'
    });
}

console.log(`Found ${steps.length} steps`);
steps.forEach((s, i) => {
    console.log(`${i}|${s.name}|${s.duration}|${s.drillId}`);
});
