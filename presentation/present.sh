#!/bin/bash

PORT=4567
NGROK="$(which ngrok)"  # Set to your ngrok path

if [[ ("$1" == '--when-execs-are-here') || ("$1" == '--live') || ("$1" == '-l') ]]; then
    grunt serve --port "$PORT" &
    PID=$!
    echo "Use \`kill $PID' to stop grunt server, or \`ps aux | grep grunt' to find it."
    eval "$NGROK -proto="http" \"$PORT\""
else
    echo 'Running locally only...'
    grunt serve --port "$PORT"
fi
echo 'Done.'
