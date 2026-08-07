require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const session = require('express-session');
const morgan = require('morgan');
const path = require('path');
const bcrypt = require('bcrypt');
const fs = require('fs');
const { execSync } = require('child_process');
const prisma = require('./utils/prisma');
const { PrismaSessionStore } = require('./utils/prismaSessionStore');
const authRoutes = require('./routes/auth');
const protectedRoutes = require('./routes/protected');
const { logger, stream } = require('./utils/logger');

const app = express();
const PORT = process.env.PORT || 5000;

// ============================================
// HELMET CONFIGURATION
// ============================================
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: [
                "'self'",
                "'unsafe-inline'",
                "'unsafe-eval'",
                "https://cdn.tailwindcss.com",
                "https://cdn.jsdelivr.net",
                "https://unpkg.com",
                "https://fonts.googleapis.com",
                "https://kit.fontawesome.com"
            ],
            styleSrc: [
                "'self'",
                "'unsafe-inline'",
                "https://fonts.googleapis.com",
                "https://cdn.tailwindcss.com",
                "https://cdn.jsdelivr.net",
                "https://unpkg.com"
            ],
            fontSrc: [
                "'self'",
                "https://fonts.gstatic.com",
                "https://fonts.googleapis.com",
                "data:"
            ],
            imgSrc: [
                "'self'",
                "data:",
                "https:",
                "http:"
            ],
            connectSrc: [
                "'self'",
                "https://cdn.tailwindcss.com",
                "https://*.googleapis.com"
            ],
            frameSrc: ["'self'"],
            objectSrc: ["'none'"],
            mediaSrc: ["'self'"],
            manifestSrc: ["'self'"],
            workerSrc: ["'self'", "blob:"],
            childSrc: ["'self'", "blob:"],
            formAction: ["'self'"],
            baseUri: ["'self'"],
            upgradeInsecureRequests: []
        }
    },
    crossOriginResourcePolicy: { policy: "cross-origin" },
    crossOriginEmbedderPolicy: false,
    crossOriginOpenerPolicy: { policy: "unsafe-none" }
}));

// CORS
app.use(cors({ 
    origin: true, 
    credentials: true 
}));

// Logging
app.use(morgan('combined', { stream }));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: 'Too many requests, please try again later.'
});
app.use('/api/auth', limiter);

// ============================================
// SESSION STORE - Using Prisma directly in abc.db
// ============================================
app.use(session({
    /* store: new PrismaSessionStore({
        table: 'sessions',
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }),*/   
    secret: process.env.SESSION_SECRET || 'default-secret',
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: process.env.NODE_ENV === 'production',
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    },
    name: 'abc.sid'
}));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/protected', protectedRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Catch-all for SPA
app.get('*', (req, res) => {
    if (req.path.startsWith('/api')) return res.status(404).json({ error: 'Not found' });
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Global error handler
app.use((err, req, res, next) => {
    logger.error(`Error: ${err.message}\nStack: ${err.stack}`);
    res.status(500).json({ error: 'Internal server error' });
});

// Initialize database
async function startServer() {
    try {
        // Ensure db directory exists
        const dbDir = path.join(__dirname, 'db');
        if (!fs.existsSync(dbDir)) {
            fs.mkdirSync(dbDir, { recursive: true });
        }

        // Push schema to database (including sessions table)
        logger.info('📦 Ensuring database schema is up to date...');
        try {
            execSync('npx prisma db push --accept-data-loss', { 
                stdio: 'inherit',
                cwd: __dirname 
            });
            logger.info('✅ Database schema ready.');
        } catch (pushError) {
            logger.warn('⚠️ Could not push schema: ' + pushError.message);
        }

        // Test database connection
        try {
            await prisma.$queryRaw`SELECT 1`;
            logger.info('✅ Database connection successful.');
        } catch (connError) {
            logger.error('❌ Database connection failed: ' + connError.message);
            process.exit(1);
        }
 
        // Seed default admin if not exists
        try {
            const admin = await prisma.user.findUnique({ where: { username: 'admin' } });
            if (!admin) {
                const hash = await bcrypt.hash('Admin@123', parseInt(process.env.BCRYPT_ROUNDS) || 10);
                await prisma.user.create({
                    data: {
                        username: 'admin',
                        email: 'admin@abctechnologies.gh',
                        password_hash: hash,
                        first_name: 'Admin',
                        last_name: 'User',
                        role: 'admin'
                    }
                });
                logger.info('✅ Default admin user created: admin / Admin@123');
            } else {
                logger.info('✅ Admin user already exists.');
            }
        } catch (seedError) {
            logger.warn('⚠️ Could not seed admin user: ' + seedError.message);
        }

        logger.info('✅ Database initialization complete.');
        logger.info(`📊 Session store: Using abc.db (${process.env.DB_FILE || 'db/abc.db'})`);

        app.listen(PORT, () => {
            logger.info(`🚀 Server running on port ${PORT}`);
            logger.info(`📡 API base: http://localhost:${PORT}/api`);
            logger.info(`🌐 Static site: http://localhost:${PORT}`);
        });
    } catch (error) {
        logger.error(`❌ Failed to start server: ${error.message}`);
        logger.error(error.stack);
        process.exit(1);
    }
}

// Graceful shutdown
process.on('SIGINT', async () => {
    await prisma.$disconnect();
    logger.info('👋 Server shut down');
    process.exit(0);
});

startServer();