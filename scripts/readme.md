Test scripts directory

Create a set of tests:

```
scripts/gen_cmd.sh 000 > scripts/run_test000.sh
```

Create test directories in tests/test000/ directory

```
sh scripts/run_test000.sh
```

Setup mezzanines to test with

```
mv mezzanine.mp4 mezzanine2.mp4 tests/test000/mezzanines/
```

Run tests
```
sh scripts/run_test000.sh
```

Analyze tests
```
bin/results.py -n tests/test000
```

View graph stats.jpg

View json stats.json

Preview videos w/metrics: previews/*.mp4

