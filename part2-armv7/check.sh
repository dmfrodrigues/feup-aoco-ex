#!/bin/bash
java -jar /usr/local/bin/visual/content/visual_headless.jar --headless $1 --td:abort --syntax --runtime --mode:completion > $1.out
if grep -q "<syntax-error" $1_log.xml ; then
    exit 1
fi
if grep -q "<runtime-error" $1_log.xml ; then
    exit 1
fi
if grep -q "WARNING: Possible infinite loop detected!" $1.out ; then
    exit 1
fi
