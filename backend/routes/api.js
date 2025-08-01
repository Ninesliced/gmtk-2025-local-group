const express = require('express');
const router = express.Router();
const db = require('../db');
const getTodaySeed = require('../seed/dailySeed');

// GET /get_seed
router.get('/get_seed', async (req, res) => {
    const seed = await getTodaySeed();
    res.json({ seed });
});

// POST /submit
router.post('/submit', async (req, res) => {
    const { pseudo, score, seed } = req.body;
    if (!pseudo || !score || !seed) return res.status(400).json({ error: 'Missing fields' });

    try {
        const existing = await db.query(
            'SELECT * FROM scores WHERE pseudo = $1 AND seed = $2',
            [pseudo, seed]
        );

        if (existing.rows.length > 0) {
            if (score > existing.rows[0].score) {
                await db.query(
                    'UPDATE scores SET score = $1 WHERE pseudo = $2 AND seed = $3',
                    [score, pseudo, seed]
                );
            }
        } else {
            await db.query(
                'INSERT INTO scores (pseudo, score, seed) VALUES ($1, $2, $3)',
                [pseudo, score, seed]
            );
        }

        res.json({ status: 'OK' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'DB error' });
    }
});

// GET /leaderboard
router.get('/leaderboard', async (req, res) => {
    const seed = await getTodaySeed();
    const result = await db.query(
        'SELECT pseudo, score FROM scores WHERE seed = $1 ORDER BY score DESC LIMIT 10',
        [seed]
    );
    res.json(result.rows);
});

// GET /rank/:pseudo
router.get('/rank/:pseudo', async (req, res) => {
    const seed = await getTodaySeed();
    const pseudo = req.params.pseudo;

    const allScores = await db.query(
        'SELECT pseudo, score FROM scores WHERE seed = $1 ORDER BY score DESC',
        [seed]
    );

    const rank = allScores.rows.findIndex(r => r.pseudo === pseudo);
    if (rank === -1) return res.status(404).json({ error: 'Pseudo not found' });

    res.json({ rank: rank + 1, score: allScores.rows[rank].score });
});

module.exports = router;
