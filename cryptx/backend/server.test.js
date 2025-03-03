const supertest = require('supertest');
const { MongoClient } = require('mongodb');
const app = require('./server'); 
require('dotenv').config({ path: '../assets/.env' });

const testConnectionString = process.env.MONGO_DB_CONNECTION_STRING;

let db;
let request;

beforeAll(async () => {
  const client = await MongoClient.connect(testConnectionString, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  db = client.db('wallet');
  request = supertest(app);
});

afterAll(async () => {
  await db.collection('transactions').deleteMany({});
  db.client.close();
});

describe('Transaction Service API', () => {
  test('POST /transactions should create a transaction', async () => {
    const newTransaction = {
      from: 'senderPublicKey',
      to: 'recipientPublicKey',
      amount: 100.0,
    };

    const response = await request.post('/transactions').send(newTransaction);

    expect(response.status).toBe(201);
    expect(response.body.from).toBe('senderPublicKey');
    expect(response.body.to).toBe('recipientPublicKey');
    expect(response.body.amount).toBe(100.0);
  });

  test('GET /transactions/sender/:sender should return transactions by sender', async () => {
    const transaction = {
      from: 'senderPublicKey',
      to: 'recipientPublicKey',
      amount: 100.0,
    };
    await db.collection('transaction').insertOne(transaction);

    const response = await request.get('/transactions/sender/senderPublicKey');
    console.log(response.body);

    expect(response.status).toBe(200);
    expect(response.body.length).toBeGreaterThan(0);
    expect(response.body[0].from).toBe('senderPublicKey');
  });

  test('GET /transactions/recipient/:recipient should return transactions by recipient', async () => {
    const transaction = {
      from: 'senderPublicKey',
      to: 'recipientPublicKey',
      amount: 100.0,
    };
    await db.collection('transaction').insertOne(transaction);

    const response = await request.get('/transactions/recipient/recipientPublicKey');

    expect(response.status).toBe(200);
    expect(response.body.length).toBeGreaterThan(0);
    expect(response.body[0].to).toBe('recipientPublicKey');
  });

  test('GET /transactions/address/:address should return transactions for a specific address', async () => {
    const transaction = {
      from: 'senderPublicKey',
      to: 'recipientPublicKey',
      amount: 100.0,
    };
    await db.collection('transaction').insertOne(transaction);

    const response = await request.get('/transactions/address/senderPublicKey');

    expect(response.status).toBe(200);
    expect(response.body.length).toBeGreaterThan(0);
    expect(response.body[0].from).toBe('senderPublicKey');
    expect(response.body[0].to).toBe('recipientPublicKey');
  });

  test('GET /transactions/sender/:sender should return empty if no transactions exist for sender', async () => {
    const response = await request.get('/transactions/sender/nonExistentSender');
    expect(response.status).toBe(200);
    expect(response.body).toEqual([]);
  });

  test('POST /transactions should fail with incomplete data', async () => {
    const incompleteTransaction = {
      from: 'senderPublicKey',
    };

    const response = await request.post('/transactions').send(incompleteTransaction);
    expect(response.status).toBe(400);
  });
});
