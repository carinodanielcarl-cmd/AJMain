const express = require('express');
const app = express();
const port = 3000;

// This mimics the format expected by the Auto Joiner
let findings = [
    {
        id: 1,
        name: "Skibidi Toilet",
        value: 100000000,
        tier: "Highlights",
        job_id: "REPLACE_WITH_ACTUAL_JOB_ID",
        base_name: "Skibidi Toilet"
    },
    {
        id: 2,
        name: "Guerriro Digitale",
        value: 50000000,
        tier: "Midlights",
        job_id: "REPLACE_WITH_ACTUAL_JOB_ID_2",
        base_name: "Guerriro Digitale"
    }
];

app.get('/recent', (req, res) => {
    res.json({
        ok: true,
        findings: findings
    });
});

// Endpoint to add new findings (for your logger)
app.use(express.json());
app.post('/log', (req, res) => {
    const newFinding = req.body;
    newFinding.id = findings.length + 1;
    findings.push(newFinding);
    // Keep only last 50
    if (findings.length > 50) findings.shift();
    res.json({ success: true });
});

app.listen(port, () => {
    console.log(`AJGODZX Logger API running at http://localhost:${port}`);
    console.log(`Use this URL in your script: http://YOUR_SERVER_IP:3000/recent`);
});
