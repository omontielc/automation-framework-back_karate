/**
 * karate-config.js
 *
 * Global configuration file automatically loaded by Karate before any test execution.
 * Defines base URLs, endpoints, timeouts, and global HTTP headers
 * available as variables across all feature files.
 *
 * @author Osiris Montiel Campos
 */
function fn() {

    // =========================================================
    // Environment setup
    // Default environment is 'QA' unless overridden via command line:
    // mvn test -Dkarate.env=staging
    // =========================================================
    var env = karate.env || 'QA';
    karate.log('Active environment:', env);

    // =========================================================
    // Global variables
    // Accessible in every feature file without any import
    // =========================================================
    var config = {

        // Base URL for JSONPlaceholder API
        apiOneBaseUrl:  'https://jsonplaceholder.typicode.com',

        // Base URL for Restful Booker API
        bookingBaseUrl: 'https://restful-booker.herokuapp.com',

        // Endpoint paths reused across scenarios
        postsEndpoint:   '/posts',
        loginEndpoint:   '/auth',
        bookingEndpoint: '/booking',

        // Maximum time in milliseconds to wait for a connection or response
        timeout: 10000
    };

    // =========================================================
    // Environment overrides
    // Swap base URLs depending on the active environment
    // =========================================================
    if (env === 'DEV') {
        config.bookingBaseUrl = 'https://dev.restful-booker.com';
    }
    if (env === 'STAGING') {
        config.bookingBaseUrl = 'https://staging.restful-booker.com';
    }

    // =========================================================
    // Global HTTP settings
    // Applied automatically to every request across all feature files
    // =========================================================

    // Maximum time to establish a connection
    karate.configure('connectTimeout', config.timeout);

    // Maximum time to wait for a server response
    karate.configure('readTimeout', config.timeout);

    // Default headers sent on every request
    // Content-Type tells the server the format of the request body
    // Accept tells the server the format expected in the response
    karate.configure('headers', {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    });

    return config;
}