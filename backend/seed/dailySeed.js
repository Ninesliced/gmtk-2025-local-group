const db = require('../db');
const crypto = require('crypto');

async function getTodaySeed() {
    const today = new Date().toISOString().split('T')[0];

    const existing = await db.query('SELECT seed FROM seeds WHERE date = $1', [today]);
    if (existing.rows.length > 0) {
        return existing.rows[0].seed;
    }

    const seed = crypto.randomBytes(Number(process.env.SEED_LENGTH) || 6).toString('hex');
    await db.query('INSERT INTO seeds (date, seed) VALUES ($1, $2)', [today, seed]);
    return seed;
}

module.exports = getTodaySeed;
