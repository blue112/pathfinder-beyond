trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

inotifywait -q -m -r -e close_write src/ ../shared/ | while read events; do haxe make.hxml && date; done &
inotifywait -q -m -r -e close_write scss/ | while read events; do sass scss/main.scss > ../backend/static/main.css && date; done &
wait