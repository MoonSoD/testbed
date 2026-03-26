import express from 'express';

const app = express();
const PORT = parseInt(process.env.PORT || '3000');
const ZONE = process.env.ZONE_NAME || 'unknown';

app.get('/health', (req, res) => {
  res.json({
    zone: ZONE,
    service: 'probe',
    reachable: true,
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`Probe service running in ${ZONE} zone on port ${PORT}`);
});
