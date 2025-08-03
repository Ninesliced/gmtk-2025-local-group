// Autorise toutes les origines
// app.use(cors());
//
const db = require('../db');
const getTodaySeed = require('../seed/dailySeed');
const express = require('express');
const cors = require('cors');

const router = express.Router();
router.use(cors());

// GET /get_seed
router.get('/get_seed', async (req, res) => {
    const seed = await getTodaySeed();
    res.json({ seed });
});

const fs = require('fs');

function loadBanWords(filePath, maxLength = 9) {
    const content = fs.readFileSync(filePath, 'utf-8');
    const words = content
    .split('\n')
    .map(line => line.trim())
    .filter(word => word.length > 0 && word.length <= maxLength);
    return words;
}

// Exemple d'utilisation
const banList = loadBanWords('banwords.txt');

function normalizePseudo(pseudo) {
    return pseudo
    .normalize("NFKD")                    // enlève les accents (é → e)
    .replace(/[\u0300-\u036f]/g, "")      // retire les diacritiques
    .replace(/[^a-zA-Z0-9]/g, "")         // supprime caractères spéciaux
    .toLowerCase()
    .replace(/[@4]/g, "a")
    .replace(/[$5]/g, "s")
    .replace(/[1!|i]/g, "i")
    .replace(/[0o]/g, "o")
    .replace(/[3]/g, "e")
    .replace(/[7]/g, "t");
}

function collapseSpacedLetters(pseudo) {
    // enlève les espaces entre lettres pour repérer des mots séparés (n i g g a → nigga)
    return pseudo.replace(/\s+/g, '');
}

function maskOffensiveWords(pseudo) {
    const normalized = normalizePseudo(pseudo);
    let masked = normalized;

    for (const banned of banList) {
        const regex = new RegExp(banned, "g");
        masked = masked.replace(regex, "*".repeat(banned.length));
    }

    return masked;
}

function isPseudoOffensive(pseudo) {
    const collapsed = collapseSpacedLetters(pseudo);
    const normalized = normalizePseudo(collapsed);
    let allMasked = true;

    for (const banned of banList) {
        const regex = new RegExp(banned, "g");
        if (normalized.includes(banned)) {
            // On fait un remplacement dans le pseudo original (normalisé)
            const masked = normalized.replace(regex, "*".repeat(banned.length));
            // Si tout le pseudo devient des étoiles, on refuse
            if (/^\*+$/.test(masked)) return true;
            // Sinon on note qu'il reste des caractères légitimes
            allMasked = false;
        }
    }

    return false;
}


// POST /submit
router.post('/submit', async (req, res) => {
    const { pseudo, score, seed } = req.body;
    if (!pseudo || !score || !seed) return res.status(400).json({ error: 'Missing fields' });
    if (pseudo.length > 9) return res.status(400).json({ error: 'Pseudo too long' });
    if (pseudo.length === 0) return res.status(400).json({ error: 'Pseudo too short' });
    if (pseudo.score > 99999999) return res.status(400).json({ error: 'Not Valid Score' });
    if (isPseudoOffensive(pseudo)) return res.status(400).json({ error: 'Offensive pseudo' });
    const normalizedPseudo = maskOffensiveWords(pseudo);
    
    try {
        const existing = await db.query(
            'SELECT * FROM scores WHERE pseudo = $1 AND seed = $2',
            [normalizedPseudo, seed]
        );

        if (existing.rows.length > 0) {
            if (score > existing.rows[0].score) {
                await db.query(
                    'UPDATE scores SET score = $1 WHERE pseudo = $2 AND seed = $3',
                    [score, normalizedPseudo, seed]
                );
            }
        } else {
            await db.query(
                'INSERT INTO scores (pseudo, score, seed) VALUES ($1, $2, $3)',
                [normalizedPseudo, score, seed]
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
        'SELECT pseudo, score FROM scores WHERE seed = $1 ORDER BY score DESC LIMIT 5',
        [seed]
    );
    res.json(result.rows);
});

// GET /rank/:pseudo
router.get('/rank/:pseudo', async (req, res) => {
    const seed = await getTodaySeed();
    const pseudo = req.params.pseudo;

    const allScores = await db.query(
        'SELECT pseudo, score FROM scores WHERE seed = $1 AND pseudo = $2 ORDER BY score DESC LIMIT 1',
        [seed, pseudo]
    );

    if (allScores.rows.length === 0) {
        return res.status(404).json({ error: 'Pseudo not found' });
    }

    res.json({ score: allScores.rows });
});

module.exports = router;
