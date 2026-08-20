# Deploy Drive Better Proxy (Cloudflare Worker)

## One-time setup

```bash
cd "/Users/taqi/StudioProjects/Drive Better/backend"
npm install
npx wrangler login          # opens browser, sign in with your Cloudflare account
```

## Set secrets

```bash
npx wrangler secret put ANTHROPIC_API_KEY
# paste your Anthropic key when prompted

npx wrangler secret put APP_TOKEN
# make up a random string, e.g. drivebetter_abc123xyz — save it, you'll need it in Flutter
```

## Deploy

```bash
npm run deploy
# You'll get a URL like: https://drive-better-proxy.<your-subdomain>.workers.dev
```

## Wire to Flutter app

Run the app with the proxy URL and token:
```bash
cd "/Users/taqi/StudioProjects/Drive Better/drive_better"
JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/jdk-21.0.7+6/Contents/Home" \
flutter run -d emulator-5554 \
  --dart-define=PROXY_BASE_URL=https://drive-better-proxy.<subdomain>.workers.dev \
  --dart-define=APP_TOKEN=drivebetter_abc123xyz
```

## Test the proxy

```bash
# Health check
curl https://drive-better-proxy.<subdomain>.workers.dev/health

# Answer endpoint
curl -X POST https://drive-better-proxy.<subdomain>.workers.dev/v1/answer \
  -H "Authorization: Bearer drivebetter_abc123xyz" \
  -H "Content-Type: application/json" \
  -d '{"question":"What does a red circle road sign mean?"}'
```

## Local dev

```bash
npm run dev
# Runs on http://localhost:8787
# Use PROXY_BASE_URL=http://10.0.2.2:8787 on Android emulator (10.0.2.2 = host localhost)
```
