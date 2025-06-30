build: lint
    cd web && tailwindcss --input main.css --output ../static/assets/main.css
    cd web && elm make src/Main.elm --output ../static/assets/main.js --optimize


lint: fmt
    uv run ruff check --fix main.py services

fmt:
    uv run ruff format --preview .
    fd -e elm | xargs elm-format --yes
