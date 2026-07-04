#!/data/data/com.termux/files/usr/bin/env bash

# config file
if [[ -f "$HOME/.config/pomo/pomorc" ]]; then
  source "$HOME/.config/pomo/pomorc"
fi

params1=$1
params2=$2
params3=$3
params4=$4

focus_duration=${params1:-${focus_duration:-45}}
break_duration=${params2:-${break_duration:-10}}
long_break_duration=${params3:-${long_break_duration:-20}}
breaks_until_long=${params4:-${breaks_until_long:-3}}
notify_audio_loop=${notify_audio_loop:-1}

echo "focus_duration: $focus_duration min"
echo "break_duration: $break_duration min"
echo "long_break_duration: $long_break_duration min"

expected_time=`date -d "+$(( (focus_duration + break_duration) * breaks_until_long + long_break_duration )) minutes" +"%p %I:%M"`
echo "It is expected to be at $expected_time"
for lu in $(seq 1 $breaks_until_long); do
  echo -ne " 🔔 until: $lu/$breaks_until_long, focus: 0:0 \033[K\r"
  for i in $(seq 1 $notify_audio_loop); do
    if [[ $phone_vibrating == "0" ]]; then
      termux-vibrate -f -d 500 &
    fi
    mpv "$HOME/.config/pomo/media/focus.mp3" --really-quiet
  done
  for fd in $(seq 0 $((focus_duration - 1))); do
    for ss in $(seq 0 59); do
      sleep 1
      echo -ne " 🍅 until: $lu/$breaks_until_long, focus: $fd:$ss \033[K\r"
    done
  done
  if [[ $lu == $breaks_until_long ]]; then
    echo -ne " 🔔 until: $lu/$breaks_until_long, lang_break: 0:0 \033[K\r"
    for i in $(seq 1 $notify_audio_loop); do
      if [[ $phone_vibrating == "0" ]]; then
        termux-vibrate -f -d 500 &
      fi
      mpv "$HOME/.config/pomo/media/long_break.mp3" --really-quiet
    done
    for lbd in $(seq 0 $((long_break_duration - 1))); do
      for ss in $(seq 0 59); do
        sleep 1
        echo -ne " 🎉 until: $lu/$breaks_until_long, long_break: $lbd:$ss \033[K\r"
      done
    done
  else
    echo -ne " 🔔 until: $lu/$breaks_until_long, break: 0:0 \033[K\r"
    for i in $(seq 1 $notify_audio_loop); do
      if [[ $phone_vibrating == "0" ]]; then
        termux-vibrate -f -d 500 &
      fi
      mpv "$HOME/.config/pomo/media/break.mp3" --really-quiet
    done
    for bd in $(seq 0 $((break_duration - 1))); do
      for ss in $(seq 0 59); do
        sleep 1
        echo -ne " 💤 until: $lu/$breaks_until_long, break: $bd:$ss \033[K\r"
      done
    done
  fi
done

echo " 🎉 $breaks_until_long pomodoro completed!               "
