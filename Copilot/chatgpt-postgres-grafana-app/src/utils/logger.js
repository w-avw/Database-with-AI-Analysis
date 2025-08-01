
// 1. Simple logger utility for consistent log formatting
//    - info: logs informational messages
//    - warn: logs warnings
//    - error: logs errors
export const logger = {
  info: (...args) => console.log('[INFO]', ...args),   // Info log
  warn: (...args) => console.warn('[WARN]', ...args), // Warning log
  error: (...args) => console.error('[ERROR]', ...args), // Error log
};