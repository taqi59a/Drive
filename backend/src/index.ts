/**
 * Drive Better — Cloudflare Worker Proxy
 *
 * Environment variables (set via `wrangler secret put`):
 *   ANTHROPIC_API_KEY  — your Anthropic key
 *   APP_TOKEN          — shared secret the Flutter app sends in Authorization header
 *
 * Endpoints:
 *   POST /v1/answer      — Camera Q&A fallback (claude-haiku-4-5)
 *   POST /v1/explain     — Get explanation for a question
 *   GET  /health         — Liveness check
 */

export interface Env {
  ANTHROPIC_API_KEY: string;
  APP_TOKEN: string;
}

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });
}

function unauthorized() {
  return json({ error: 'Unauthorized' }, 401);
}

function badRequest(msg: string) {
  return json({ error: msg }, 400);
}

function isAuthorized(request: Request, env: Env): boolean {
  const auth = request.headers.get('Authorization') ?? '';
  return auth === `Bearer ${env.APP_TOKEN}`;
}

async function callClaude(
  env: Env,
  model: string,
  systemPrompt: string,
  userMessage: string | Array<any>,
  maxTokens = 512,
): Promise<string> {
  const content = typeof userMessage === 'string'
    ? [{ type: 'text', text: userMessage }]
    : userMessage;

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': env.ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model,
      max_tokens: maxTokens,
      system: systemPrompt,
      messages: [{ role: 'user', content }],
    }),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Anthropic API error ${response.status}: ${err}`);
  }

  const data = (await response.json()) as {
    content: Array<{ type: string; text: string }>;
  };
  return data.content.find((c) => c.type === 'text')?.text ?? '';
}

// ---------------------------------------------------------------------------
// POST /v1/answer — camera Q&A fallback
// Body: { question: string, context?: string, image?: string }
// Returns: { answer: string, explanation: string, confidence: number } or { discard: true, reason: string }
// ---------------------------------------------------------------------------
async function handleAnswer(request: Request, env: Env): Promise<Response> {
  if (!isAuthorized(request, env)) return unauthorized();

  let body: { question?: string; context?: string; image?: string };
  try {
    body = await request.json();
  } catch {
    return badRequest('Invalid JSON body');
  }

  const { question, context, image } = body;
  if (!question || typeof question !== 'string' || question.trim().length < 3) {
    return badRequest('question is required and must be at least 3 characters');
  }

  const system = `You are an expert Belgian driving theory test tutor.
Analyze the question and image strictly according to Belgian traffic rules.

If an image is provided, first perform validation:
1. Verify if the image contains or displays a driving theory test question (which could be photographed from a computer monitor/screen, cropped, or a direct screenshot/document).
2. Verify if the question is written in English, Dutch, or French, and is related to driving rules/theory.
If the image does NOT contain a driving theory test question (e.g. it is a random object, a photo of a room, or unrelated text), or if it is in an unsupported language, you MUST reject/discard it immediately. To discard, respond with exactly this JSON:
{"discard":true,"reason":"<brief explanation of why it was discarded, e.g., No driving theory test question detected>"}

If valid (or if no image is provided):
- Carefully analyze the question text and option choices.
- If there is an image, analyze any traffic situation, illustration, road signs, or road markings carefully to determine the correct answer.
- Return the correct answer option and explanation strictly based on Belgian traffic regulations.
- Respond with valid JSON in exactly this format:
{"answer":"<the correct answer choice text>","explanation":"<why it is correct based on Belgian traffic rules, 1-2 sentences>","confidence":0.95}

Ensure the response contains ONLY the raw JSON string. Do not wrap it in markdown code blocks.`;

  try {
    let userMsg: string | Array<any>;
    let model = 'claude-3-5-haiku-20241022';

    if (image && image.trim().length > 100) {
      let mediaType = 'image/jpeg';
      let base64Data = image.trim();
      
      const matchDataUrl = base64Data.match(/^data:(image\/[a-zA-Z+]+);base64,(.*)$/);
      if (matchDataUrl) {
        mediaType = matchDataUrl[1];
        base64Data = matchDataUrl[2];
      }

      userMsg = [
        {
          type: 'text',
          text: context
            ? `Context from OCR: ${context}\n\nQuestion: ${question}`
            : `Question: ${question}`
        },
        {
          type: 'image',
          source: {
            type: 'base64',
            media_type: mediaType,
            data: base64Data
          }
        }
      ];
      // Use Sonnet for vision requests to get the highest accuracy on screenshots/signs
      model = 'claude-3-5-sonnet-20241022';
    } else {
      userMsg = context
        ? `Context from OCR: ${context}\n\nQuestion: ${question}`
        : `Question: ${question}`;
    }

    const raw = await callClaude(env, model, system, userMsg, 300);
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error('No JSON in response');
    const parsed = JSON.parse(jsonMatch[0]);
    return json(parsed);
  } catch (e) {
    return json({ error: String(e) }, 502);
  }
}

// ---------------------------------------------------------------------------
// POST /v1/explain — get a detailed explanation for a question
// Body: { question: string, correctAnswer: string, wrongAnswer?: string }
// Returns: { explanation: string }
// ---------------------------------------------------------------------------
async function handleExplain(request: Request, env: Env): Promise<Response> {
  if (!isAuthorized(request, env)) return unauthorized();

  let body: { question?: string; correctAnswer?: string; wrongAnswer?: string };
  try {
    body = await request.json();
  } catch {
    return badRequest('Invalid JSON body');
  }

  const { question, correctAnswer, wrongAnswer } = body;
  if (!question || !correctAnswer) {
    return badRequest('question and correctAnswer are required');
  }

  const system = `You are a Belgian driving theory test tutor.
Give a clear, friendly explanation of why the correct answer is right.
Keep it to 2-3 sentences. Reference Belgian traffic regulations where relevant.
Respond with JSON: {"explanation":"<your explanation>"}`;

  const wrongPart = wrongAnswer
    ? `\nThe student chose: "${wrongAnswer}" (which is wrong).`
    : '';

  const userMsg = `Question: ${question}\nCorrect answer: "${correctAnswer}"${wrongPart}`;

  try {
    const raw = await callClaude(env, 'claude-3-5-haiku-20241022', system, userMsg, 200);
    const match = raw.match(/\{[\s\S]*\}/);
    if (!match) throw new Error('No JSON in response');
    const parsed = JSON.parse(match[0]);
    return json(parsed);
  } catch (e) {
    return json({ error: String(e) }, 502);
  }
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    const url = new URL(request.url);

    if (url.pathname === '/health' && request.method === 'GET') {
      return json({ status: 'ok', version: '1.0.0' });
    }

    if (url.pathname === '/v1/answer' && request.method === 'POST') {
      return handleAnswer(request, env);
    }

    if (url.pathname === '/v1/explain' && request.method === 'POST') {
      return handleExplain(request, env);
    }

    return json({ error: 'Not found' }, 404);
  },
};
