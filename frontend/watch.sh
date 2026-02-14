while inotifywait -r -e close_write src/ ../shared/; do haxe make.hxml && date; done &
while inotifywait -r -e close_write scss/; do sass scss/main.scss > ../backend/static/main.css && date; done &
wait