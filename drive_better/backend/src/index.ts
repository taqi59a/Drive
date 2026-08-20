/**
 * Drive Better — Claude API Proxy (Cloudflare Worker)
 * Holds ANTHROPIC_API_KEY server-side. App calls this with APP_TOKEN.
 * Deploy: wrangler deploy
 */

interface Env {
  ANTHROPIC_API_KEY: string;
  APP_TOKEN: string;
}

interface AnswerRequest {
  question: string;
  options?: string[];
  context?: string;
}

interface AnswerResponse {
  answer: string;
  explanation: string;
  confidence: number;
}

const SYSTEM_PROMPT = `You are an expert UK driving theory test examiner.
When given a driving theory question (possibly from OCR so may have minor errors),
provide the correct answer and a clear explanation.

Always respond with valid JSON in exactly this format:
{
  "answer": "the correct answer text",
  "explanation": "clear explanation why this is correct (2-3 sentences)",
  "confidence": 0.95
}

Base your answers on the UK Highway Code and DVSA standards.
Be concise and accurate. Confidence should reflect how certain you are (0.0-1.0).`;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405, headers: corsHeaders });
    }

    // Validate app token
    const authHeader = request.headers.get('Authorization');
    const token = authHeader?.replace('Bearer ', '');
    if (token !== env.APP_TOKEN) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    let body: AnswerRequest;
    try {
      body = await request.json();
    } catch {
      return new Response(JSON.stringify({ error: 'Invalid JSON' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (!body.question?.trim()) {
      return new Response(JSON.stringify({ error: 'question is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const userPrompt = buildUserPrompt(body);

    try {
      const response = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: {
          'x-api-key': env.ANTHROPIC_API_KEY,
          'anthropic-version': '2023-06-01',
          'anthropic-beta': 'prompt-caching-2024-07-31',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'claude-haiku-4-5',
          max_tokens: 512,
          system: [
            {
              type: 'text',
              text: SYSTEM_PROMPT,
              cache_control: { type: 'ephemeral' },
            },
          ],
          messages: [{ role: 'user', content: userPrompt }],
        }),
      });

      if (!response.ok) {
        const err = await response.text();
        console.error('Anthropic API error:', err);
        return new Response(JSON.stringify({ error: 'AI service error' }), {
          status: 502,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      const data: any = await response.json();
      const rawText = data.content?.[0]?.text ?? '';

      // Parse JSON from response
      let parsed: AnswerResponse;
      try {
        const jsonMatch = rawText.match(/\{[\s\S]*\}/);
        parsed = JSON.parse(jsonMatch?.[0] ?? rawText);
      } catch {
        parsed = {
          answer: rawText.slice(0, 200),
          explanation: 'Based on UK Highway Code guidelines.',
          confidence: 0.7,
        };
      }

      return new Response(JSON.stringify(parsed), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    } catch (err) {
      console.error('Worker error:', err);
      return new Response(JSON.stringify({ error: 'Internal error' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }
  },
};

function buildUserPrompt(body: AnswerRequest): string {
  let prompt = `Question: ${body.question}`;
  if (body.options?.length) {
    prompt += '\n\nOptions:\n' + body.options.map((o, i) => `${String.fromCharCode(65 + i)}. ${o}`).join('\n');
  }
  if (body.context) {
    prompt += `\n\nContext: ${body.context}`;
  }
  prompt += '\n\nRespond with JSON only.';
  return prompt;
}
