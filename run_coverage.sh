#!/bin/bash

# Run Dart test coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=lcov.info --report-on=lib

# Extract and print total coverage score
total_coverage=$(lcov --summary lcov.info 2>/dev/null | grep 'lines.......:' | grep -o '[0-9.]*%' | head -1)

if [ ! -z "$total_coverage" ]; then
    echo "Total Coverage: ${total_coverage}"
else
    echo "Coverage data not found"
fi

# Open coverage report if --open flag is passed
if [ "$1" = "--open" ]; then
    genhtml lcov.info -o coverage_html >/dev/null 2>&1
    open coverage_html/index.html
fi
