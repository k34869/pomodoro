#!/usr/bin/env bash

# config file
if [[ -f "$HOME/.config/pomo/pomorc" ]]; then
  source "$HOME/.config/pomo/pomorc"
fi

set -eo pipefail

EXIT_PID=$$
focus_duration=${1:-${focus_duration:-45}}
break_duration=${2:-${break_duration:-10}}
long_break_duration=${3:-${long_break_duration:-20}}
breaks_until_long=${4:-${breaks_until_long:-3}}
notify_audio_loop=$((${notify_audio_loop:-1} - 1))
extend_command=${5:-$extend_command}

echo "Focus duration: $focus_duration min"
echo "Break duration: $break_duration min"
echo "Long break duration: $long_break_duration min"
echo "It is expected to be at $(date -d "+$(( (focus_duration + break_duration) * breaks_until_long + long_break_duration )) minutes" +"%p %I:%M")"

if [[ ! $extend_command =~ ^[[:space:]]*$ ]]; then
  echo "Execute extend command: $extend_command"
  eval "$extend_command &" &> /dev/null
  EXIT_PID=$!
fi

write_nodone_log() {
  echo "$(date +%Y%m%d%H%M):$focus_duration:$break_duration:$breaks_until_long:NO" >> $HOME/.pomo.log
}

# $1 duration, $2 text, $3 emoji, $4 current_breaks_until_long
timer() {
  local reduration=0$1
  echo -ne " 🔔 until: $4/$breaks_until_long, $2: ${reduration: -2}:00 \033[K\r"
  mpv "$HOME/.config/pomo/media/$2.mp3" --no-video --loop=$notify_audio_loop --really-quiet
  for d in $(seq 1 $1); do
    for ss in {0..59}; do
      sleep 1
      local remin=0$(($1 - d))
      local ress=0$((59 - ss))
      echo -ne " $3 until: $4/$breaks_until_long, $2: ${remin: -2}:${ress: -2} \033[K\r"
    done
  done
}

trap write_nodone_log SIGINT

for lu in $(seq 1 $breaks_until_long); do
  timer $focus_duration focus 🍅 $lu
  if [[ $lu == $breaks_until_long ]]; then
    timer $long_break_duration long_break 🎉 $lu
  else
    timer $break_duration break 💤 $lu
  fi
done

echo "$(date +%Y%m%d%H%M):$focus_duration:$break_duration:$breaks_until_long:YES" >> $HOME/.pomo.log
echo " 🎉 $breaks_until_long pomodoro completed!               "
kill $EXIT_PID 2> /dev/null