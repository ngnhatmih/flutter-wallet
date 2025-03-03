require('dotenv').config({ path: '../assets/.env' });
const cors = require('cors');
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
app.use(cors());
app.use(express.json());

const connectionString = process.env.MONGO_DB_CONNECTION_STRING;
let db;

MongoClient.connect(connectionString, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(client => {
    db = client.db('wallet');
    app.listen(5000, () => { console.log('Server is running on http://127.0.0.1:5000') });
  })
  .catch(err => console.error('Failed to connect to MongoDB', err));

app.get('/transactions/sender/:sender', async (req, res) => {
  const { sender } = req.params;
  try {
    const transactions = await db.collection('transactions').find({ from: sender }).toArray();
    res.json(transactions);
  } catch (err) {
    res.status(500).send('Error fetching transactions');
  }
});

app.get('/transactions/recipient/:recipient', async (req, res) => {
  const { recipient } = req.params;
  try {
    const transactions = await db.collection('transactions').find({ to: recipient }).toArray();
    res.json(transactions);
  } catch (err) {
    res.status(500).send('Error fetching transactions');
  }
});

app.get('/transactions/address/:address', async (req, res) => {
  const { address } = req.params;
  try {
    const transactions = await db.collection('transactions').find({ $or: [{ from: address }, { to: address }] }).toArray();
    res.json(transactions);
  } catch (err) {
    res.status(500).send('Error fetching transactions');
  }
});

app.post('/transactions', async (req, res) => {
  try {
    const transaction = req.body;
    if (!transaction.from || !transaction.to || !transaction.amount) {
      return res.status(400).send('Invalid transaction data');
    }
    const result = await db.collection('transactions').insertOne(transaction);

    res.status(201).send({
      ...transaction,
      _id: result.insertedId 
    });
  } catch (err) {
    console.error('Error creating transaction:', err);
    res.status(500).send('Error creating transaction');
  }
});

module.exports = app;
