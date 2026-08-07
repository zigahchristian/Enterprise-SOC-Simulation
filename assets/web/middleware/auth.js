const prisma = require('../utils/prisma');

const authMiddleware = (req, res, next) => {
    if (!req.session || !req.session.userId) {
        return res.status(401).json({ error: 'Unauthorized: Please log in' });
    }
    next();
};

const attachUser = async (req, res, next) => {
    if (req.session && req.session.userId) {
        const user = await prisma.user.findUnique({
            where: { id: req.session.userId }
        });
        if (user) {
            req.user = user;
        }
    }
    next();
};

module.exports = { authMiddleware, attachUser };