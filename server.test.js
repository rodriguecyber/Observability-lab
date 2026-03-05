import request from 'supertest';
import app from './server.js';

describe('Simple Node.js App', () => {
  test('GET / should return Hello World', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ message: 'Hello from jenkins' });
  });

  test('GET /health should return status ok', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
    expect(response.body).toHaveProperty('timestamp');
    expect(response.body).toHaveProperty('uptime');
  });

  test('GET /metrics should return Prometheus text format', async () => {
    const response = await request(app).get('/metrics');
    expect(response.status).toBe(200);
    expect(response.headers['content-type']).toMatch(/text\/plain/);
    expect(response.text).toMatch(/http_requests_total|http_request_duration_seconds|# HELP/);
  });

  test('GET /simulate-error should return 500', async () => {
    const response = await request(app).get('/simulate-error');
    expect(response.status).toBe(500);
    expect(response.body).toHaveProperty('error');
  });
});