// Busca a cotação de um FII na brapi.dev mantendo o token só no servidor
// (a Netlify guarda a variável BRAPI_TOKEN, ela nunca chega ao navegador).
exports.handler = async (event) => {
  const ticker = event.queryStringParameters && event.queryStringParameters.ticker;
  if (!ticker) {
    return { statusCode: 400, body: JSON.stringify({ error: 'ticker obrigatório' }) };
  }

  const token = process.env.BRAPI_TOKEN;
  const url = `https://brapi.dev/api/quote/${encodeURIComponent(ticker)}?fundamental=true&token=${token}`;

  const r = await fetch(url);
  const data = await r.text();

  return {
    statusCode: r.status,
    headers: { 'Content-Type': 'application/json' },
    body: data,
  };
};
