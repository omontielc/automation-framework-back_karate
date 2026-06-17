package runner;

import com.intuit.karate.junit5.Karate;

/**
 * TestRunner
 * Test execution entry point Karate Framework.
 * * @author Osiris Montiel Campos
 */
class TestRunner {

    /**
     * Executes all feature files located under the 'classpath:api' directory.
     */
    @Karate.Test
    Karate runAll() {
        return Karate.run("classpath:api");
    }

    /**
     * Executes specific functional features related to the Booking module.
     */
    @Karate.Test
    Karate runBooking() {
        return Karate.run("classpath:api/booking");
    }

    /**
     * Executes specific functional features related to the Posts module.
     */
    @Karate.Test
    Karate runPosts() {
        return Karate.run("classpath:api/posts");
    }
}