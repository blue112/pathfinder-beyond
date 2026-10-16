trap 'kill $(jobs -p)' EXIT

haxe --wait 7748 &
(cd backend && npm run watch) &
(cd frontend && ./watch.sh) &
wait
