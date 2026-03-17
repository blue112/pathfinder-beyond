set -e

(cd frontend && haxe make.hxml)
sass frontend/scss/main.scss > backend/static/main.css