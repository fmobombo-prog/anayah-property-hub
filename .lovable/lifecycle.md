# Lifecycle Scripts

## dev

```bash
python3 -m http.server 8080 --bind 0.0.0.0
```

## build:dev

```bash
mkdir -p dist && cp index.html config.js favicon.svg apple-touch-icon.png icon-192.png icon-512.png manifest.webmanifest dist/
```

## build

```bash
mkdir -p dist && cp index.html config.js favicon.svg apple-touch-icon.png icon-192.png icon-512.png manifest.webmanifest dist/
```
