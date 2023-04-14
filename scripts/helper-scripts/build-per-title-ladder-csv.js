const args = require('minimist')(process.argv.slice(2));
const fs = require('fs');
const path = require('path');

let folder = args.folder;
let topTierTarget = parseInt(args.target);
let desiredTiers = parseInt(args.tiersDesired);

let files = fs.readdirSync(folder);

// Focus on vmaf files only
files = files.filter(d => d.endsWith('_vmaf.json'));

let tierScores = [];
files.forEach(f => {
    let fullPath = path.join(folder, f);
    let filenameParts = f.split('_');
    let tier = filenameParts[filenameParts.length - 3];
    
    let height = tier.split('p')[0];
    let bitrate = tier.split('p')[1].split('X')[0];

    let contents = fs.readFileSync(fullPath, { encoding: 'utf-8' });
    let avg = JSON.parse(contents);

    tierScores.push({
        height: height,
        bitrate: parseInt(bitrate),
        vmaf: avg.avg[0]
    });
});

tierScores = tierScores.sort((a, b) => b.bitrate - a.bitrate);

let tierResults = [findLowestBitrateOverVmaf(tierScores, topTierTarget)];
let tierFound = true;
let lastBitrateFound = tierResults[0].bitrate;

while (tierFound && tierResults.length < desiredTiers) {
    let targetBitrate = lastBitrateFound * .6;
    let maxBitrate = targetBitrate + 200;
    let minBitrate = targetBitrate - 200;

    let nextTier = findHighestVmafInBitrateRange(tierScores, maxBitrate, minBitrate, tierResults);
    if (nextTier) {
        tierResults.push(nextTier);
        lastBitrateFound = nextTier.bitrate;
    } else {
        tierFound = false;
    }
}

function findLowestBitrateOverVmaf(tiers, vmafTarget){
    let returning = tiers[0];

    tiers.forEach(t => {
        if (t.bitrate < returning.bitrate && t.vmaf > vmafTarget) {
            returning = t;
        }
    });

    if (returning.vmaf < vmafTarget) {
        returning = tiers.sort((a, b) => b.vmaf - a.vmaf)[0];
    }

    return returning;
}

function findHighestVmafInBitrateRange(tiers, maxBitrate, minBitrate, existingTiers){
    let filtered = tiers.filter(t => {
        let fits = t.bitrate >= minBitrate && t.bitrate <= maxBitrate
        if (!fits) {
            return false;
        } else {
            let matching = existingTiers.filter(e => e.bitrate == t.bitrate);
            if (matching.length > 0){
                return false;
            }

            return true;
        }
    });


    if (filtered.length > 0){
        return filtered.sort((a, b) => b.vmaf - a.vmaf)[0];
    }

    return undefined;
}

// Organize by bit-rate so we can build a proper csv for generating graphs
let bitrates = [];
let heights = ['ideal ladder'];
tierScores.forEach(t => {
    if (bitrates.indexOf(t.bitrate) < 0){
        bitrates.push(t.bitrate);
    }
    if (heights.indexOf(t.height) < 0){
        heights.push(t.height);
    }
});
heights = heights.sort((a, b) => a - b);
bitrates = bitrates.sort((a, b) => a - b);

let results = [];
let firstRow = ['bitrate'];
heights.forEach(h => {
    firstRow.push(h);
});
results.push(firstRow);

bitrates.forEach(b => {
    let row = [b];
    for (let i = 0; i < heights.length; i++){
        if (i == 0) {
            // Ideal ladder row
            let idealTier = tierResults.filter(tr => tr.bitrate == b);
            if (idealTier.length > 0) {
                row.push(idealTier[0].vmaf);
            } else {
                row.push('-');
            }
        } else {
            let height = heights[i];
            let tier = tierScores.filter(ts => ts.height == height && ts.bitrate == b);
            if (tier.length > 0) {
                row.push(tier[0].vmaf);
            } else {
                row.push('');
            }
        }
    }
    results.push(row);
});

console.log(results.map(r => r.join(',')).join('\n'));
