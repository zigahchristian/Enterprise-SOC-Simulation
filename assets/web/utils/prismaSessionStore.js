const { EventEmitter } = require('events');
const crypto = require('crypto');
const prisma = require('./prisma');

/**
 * Prisma-based session store for express-session
 * Stores sessions directly in the abc.db database
 */
class PrismaSessionStore extends EventEmitter {
    constructor(options = {}) {
        super();
        this.table = options.table || 'sessions';
        this.maxAge = options.maxAge || 24 * 60 * 60 * 1000; // 24 hours default
        this.prisma = prisma;
        this.emit('connect');
        
        // Clean up expired sessions periodically (every hour)
        setInterval(() => this.cleanupExpiredSessions(), 60 * 60 * 1000);
    }

    /**
     * Clean up expired sessions from database
     */
    async cleanupExpiredSessions() {
        try {
            const result = await this.prisma.session.deleteMany({
                where: {
                    expires: {
                        lt: new Date()
                    }
                }
            });
            if (result.count > 0) {
                console.log(`🧹 Cleaned up ${result.count} expired sessions`);
            }
        } catch (error) {
            console.error('Error cleaning up sessions:', error);
        }
    }

    /**
     * Get a session by ID
     */
    get(sid, callback) {
        this.prisma.session.findUnique({
            where: { sid }
        })
        .then(session => {
            if (!session) {
                return callback(null, null);
            }
            
            // Check if session has expired
            if (session.expires < new Date()) {
                // Delete expired session
                this.destroy(sid, () => {});
                return callback(null, null);
            }
            
            try {
                // Parse the stored JSON session data
                const sessionData = JSON.parse(session.data);
                callback(null, sessionData);
            } catch (error) {
                callback(error);
            }
        })
        .catch(error => {
            callback(error);
        });
    }

    /**
     * Set/Create a session
     */
    set(sid, session, callback) {
        // Calculate expiry time
        const expires = session.cookie && session.cookie.expires 
            ? new Date(session.cookie.expires) 
            : new Date(Date.now() + this.maxAge);
        
        // Serialize session data to JSON string
        const sessionData = JSON.stringify(session);
        
        this.prisma.session.upsert({
            where: { sid },
            update: {
                expires: expires,
                data: sessionData,
                updatedAt: new Date()
            },
            create: {
                sid: sid,
                expires: expires,
                data: sessionData
            }
        })
        .then(() => {
            callback(null);
        })
        .catch(error => {
            callback(error);
        });
    }

    /**
     * Destroy/Delete a session
     */
    destroy(sid, callback) {
        this.prisma.session.delete({
            where: { sid }
        })
        .then(() => {
            callback(null);
        })
        .catch(error => {
            // If session doesn't exist, it's fine
            if (error.code === 'P2025') {
                callback(null);
            } else {
                callback(error);
            }
        });
    }

    /**
     * Get total number of sessions
     */
    length(callback) {
        this.prisma.session.count()
        .then(count => {
            callback(null, count);
        })
        .catch(error => {
            callback(error);
        });
    }

    /**
     * Clear all sessions
     */
    clear(callback) {
        this.prisma.session.deleteMany()
        .then(() => {
            callback(null);
        })
        .catch(error => {
            callback(error);
        });
    }

    /**
     * Touch a session (update expiry time)
     */
    touch(sid, session, callback) {
        const expires = session.cookie && session.cookie.expires 
            ? new Date(session.cookie.expires) 
            : new Date(Date.now() + this.maxAge);
        
        this.prisma.session.update({
            where: { sid },
            data: {
                expires: expires,
                updatedAt: new Date()
            }
        })
        .then(() => {
            callback(null);
        })
        .catch(error => {
            callback(error);
        });
    }

    /**
     * Create a new session (called by express-session)
     */
    createSession(req, session, callback) {
        // Generate a session ID if not provided
        const sid = req.sessionID || crypto.randomBytes(32).toString('hex');
        
        // Set the session
        this.set(sid, session, (err) => {
            if (err) return callback(err);
            req.sessionID = sid;
            callback(null, sid);
        });
    }
}

module.exports = { PrismaSessionStore };