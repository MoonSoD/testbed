import express from 'express';
import { createClient } from 'redis';

const app = express();
const PORT = 5001;
const REDIS_HOST = process.env.REDIS_HOST || 'protected-redis';
const REDIS_PORT = parseInt(process.env.REDIS_PORT || '6379');

app.use(express.json());

const redisClient = createClient({
  socket: { host: REDIS_HOST, port: REDIS_PORT }
});

redisClient.on('error', (err) => console.error('Redis error:', err));
redisClient.connect().catch(() => console.log('Redis not available'));

app.get('/health', (req, res) => {
  res.json({
    zone: 'service',
    service: 'api',
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

app.get('/status', (req, res) => {
  res.json({
    zone: 'service',
    message: 'Service API is running',
    timestamp: new Date().toISOString()
  });
});

app.get('/data', async (req, res) => {
  try {
    const keys = await redisClient.keys('*');
    const data: Record<string, string> = {};
    for (const key of keys) {
      const value = await redisClient.get(key);
      if (value) data[key] = value;
    }
    res.json({ source: 'protected', data });
  } catch {
    res.status(503).json({ error: 'Protected zone unavailable' });
  }
});

app.listen(PORT, () => {
  console.log(`Service API running on port ${PORT}`);
});
