const express = require('express');
const { authMiddleware, attachUser } = require('../middleware/auth');
const router = express.Router();

router.use(authMiddleware);
router.use(attachUser);

router.get('/dashboard', (req, res) => {
    const user = req.session.user;
    res.json({
        user: {
            id: user.id,
            username: user.username,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            role: user.role
        },
        stats: {
            alerts: 14,
            openIncidents: 2,
            threatsBlocked: 1247,
            systemHealth: '98%'
        },
        recentEvents: [
            { time: '14:32', event: 'Failed SSH Login (×5)', source: '10.0.1.45', severity: 'Medium', status: 'Investigating' },
            { time: '13:15', event: 'Port Scan Detected', source: '10.0.2.12', severity: 'High', status: 'Resolved' },
            { time: '11:02', event: 'Malware Blocked (EICAR)', source: 'endpoint-07', severity: 'Critical', status: 'Contained' }
        ]
    });
});

router.get('/profile', (req, res) => {
    const user = req.user;
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }
    res.json({
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role,
        lastLogin: user.last_login,
        createdAt: user.created_at
    });
});

module.exports = router;