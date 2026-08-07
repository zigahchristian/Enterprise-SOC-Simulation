const express = require('express');
const bcrypt = require('bcrypt');
const prisma = require('../utils/prisma');
const router = express.Router();

// POST /api/auth/login
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        if (!username || !password) {
            return res.status(400).json({ error: 'Username and password required' });
        }

        // Find user by username or email
        let user = await prisma.user.findUnique({ where: { username } });
      
        if (!user) {
            user = await prisma.user.findUnique({ where: { email: username } });
        }
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        if (!user.is_active) {
            return res.status(401).json({ error: 'Account disabled' });
        }

        const valid = await bcrypt.compare(password, user.password_hash);
        if (!valid) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Update last login
        await prisma.user.update({
            where: { id: user.id },
            data: { last_login: new Date() }
        });

        // Create session
        req.session.userId = user.id;
        req.session.user = {
            id: user.id,
            username: user.username,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            role: user.role
        };


        const { password_hash, ...userInfo } = user;
        res.json({ message: 'Login successful', user: userInfo });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// POST /api/auth/logout
router.post('/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) return res.status(500).json({ error: 'Could not log out' });
        res.clearCookie('abc.sid');
        res.json({ message: 'Logged out successfully' });
    });
});

// POST /api/auth/register
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, firstName, lastName, role } = req.body;
        if (!username || !email || !password) {
            return res.status(400).json({ error: 'Username, email, and password required' });
        }

        // Check if user exists
        const existing = await prisma.user.findUnique({ where: { username } });
        if (existing) {
            return res.status(400).json({ error: 'Username already taken' });
        }
        const existingEmail = await prisma.user.findUnique({ where: { email } });
        if (existingEmail) {
            return res.status(400).json({ error: 'Email already registered' });
        }

        const password_hash = await bcrypt.hash(password, parseInt(process.env.BCRYPT_ROUNDS) || 10);

        const newUser = await prisma.user.create({
            data: {
                username,
                email,
                password_hash,
                first_name: firstName || null,
                last_name: lastName || null,
                role: role || 'employee'
            }
        });

        const { password_hash: _, ...userInfo } = newUser;
        res.status(201).json({ message: 'User created successfully', user: userInfo });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// GET /api/auth/me
router.get('/me', async (req, res) => {
    if (!req.session || !req.session.userId) {
        return res.status(401).json({ error: 'Not authenticated' });
    }
    const user = await prisma.user.findUnique({
        where: { id: req.session.userId }
    });
    if (!user) {
        req.session.destroy();
        return res.status(401).json({ error: 'User not found' });
    }
    const { password_hash, ...userInfo } = user;
    res.json(userInfo);
});

module.exports = router;