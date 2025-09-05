export default async function handler(req, res) {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).json({});
  }

  return res.status(200).json({
    mp_public_key: process.env.MP_PUBLIC_KEY || '',
    environment: process.env.NODE_ENV || 'production'
  });
}
