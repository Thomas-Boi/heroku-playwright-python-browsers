#!/usr/bin/env bash

# export the file path as a ENV
# this is meant to be copied over to the $BUILD_DIR under the same path as it currently is and then run
CHROMIUM_PATH=${find ~+ -type f -name "chrome":-NULL}
FIREFOX_PATH=${find ~+ -type f -name "firefox":-NULL}
WEBKIT_PATH=${find ~+ -type f -name "pw_run.sh":-NULL} # see https://github.com/microsoft/playwright/issues/2923

echo "----> CHROMIUM_EXECUTABLE_PATH is $CHROMIUM_PATH"
echo "----> FIREFOX_EXECUTABLE_PATH is $FIREFOX_PATH"
echo "----> WEBKIT_EXECUTABLE_PATH is $WEBKIT_PATH"

if [ "$CHROMIUM_EXECUTABLE_PATH" != "NULL" ]; then
  export CHROMIUM_EXECUTABLE_PATH=$CHROMIUM_PATH
fi

if [ "$FIREFOX_EXECUTABLE_PATH" != "NULL" ]; then
  export FIREFOX_EXECUTABLE_PATH=$FIREFOX_PATH
fi

if [ "$WEBKIT_EXECUTABLE_PATH" != "NULL" ]; then
  export WEBKIT_EXECUTABLE_PATH=$WEBKIT_PATH
fi