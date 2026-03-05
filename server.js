import express from 'express';
import { register, collectDefaultMetrics, Counter, Histogram } from 'prom-client';

const app = express();
const PORT = process.env.PORT || 4000;

collectDefaultMetrics({ prefix: 'node_' });

const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
});

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
});

app.use(express.json());

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const path = req.route?.path ?? req.path;
    httpRequestsTotal.inc({ method: req.method, path, status: res.statusCode });
    httpRequestDuration.observe({ method: req.method, path, status: res.statusCode }, duration);
  });
  next();
});

app.get('/', (req, res) => {
  res.json({ message: 'Hello from jenkins' });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: Math.floor(process.uptime()),
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/simulate-error', (req, res, next) => {
  next(new Error('Simulated error for alert testing'));
});

app.use((error, req, res, next) => {
  console.error(error);
  res.status(500).json({ error: 'Internal server error' });
});

if (import.meta.url === `file://${process.argv[1]}`) {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}

export default app;
