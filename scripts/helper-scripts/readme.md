# Helper Scripts
A set of helper scripts designed to work in conjunction with the objective_perceptual_analysis tool

### generate-objective-perceptual-analysis-tiers.js
This script generates a list of tiers that can be run through the objective_perceptual_analysis tool to calculate metrics for that tier.

Example run command:
> node generate-objective-perceptual-analysis-tiers.js

### build-per-title-ladder.js
This script takes in a folder, target vmaf score for top tier, and the desired number of tiers and builds a per-title ladder based off the metrics it finds in that folder.

In order to run you need to first install the npm packages (will need to install npm if not already installed):
> npm i

Example run command: 
> node build-per-title-ladder-csv.js --folder=../../tests/test000/results/ --target=95 --tiersDesired=5
