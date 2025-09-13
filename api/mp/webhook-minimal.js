export default function handler(req, res) {
  res.status(200).json({ 
    message: "Minimal webhook working",
    method: req.method,
    timestamp: new Date().toISOString()
  });
}