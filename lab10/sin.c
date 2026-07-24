#define _POSIX_C_SOURCE 199309L

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "lab10.h"

#define LENGTH 5000000ULL
#define REPEATS 3

/*
 * Calculate sin() for every input element using the C standard library.
 */
void sin_stdlib(double* input, double* output, uint64_t length) {
    for (uint64_t i = 0; i < length; i++) {
        output[i] = sin(input[i]);
    }
}

/*
 * Return the number of seconds between two timespec values.
 */
static double elapsed_seconds(
    struct timespec start,
    struct timespec end
) {
    return (end.tv_sec - start.tv_sec)
        + (end.tv_nsec - start.tv_nsec) / 1e9;
}

/*
 * Time one call to an array sine function.
 */
static double time_function(
    void function(double*, double*, uint64_t),
    double* input,
    double* output,
    uint64_t length
) {
    struct timespec start;
    struct timespec end;

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start);
    function(input, output, length);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end);

    return elapsed_seconds(start, end);
}

int main(void) {
    const double pi = 3.14159265358979323846;

    double* input = malloc(LENGTH * sizeof(double));
    double* x87_output = malloc(LENGTH * sizeof(double));
    double* stdlib_output = malloc(LENGTH * sizeof(double));

    if (
        input == NULL
        || x87_output == NULL
        || stdlib_output == NULL
    ) {
        fprintf(stderr, "Could not allocate arrays.\n");

        free(input);
        free(x87_output);
        free(stdlib_output);
        return 1;
    }

    /*
     * Fill the input array with values from -pi to pi.
     */
    for (uint64_t i = 0; i < LENGTH; i++) {
        double fraction = (double)i / (double)(LENGTH - 1);
        input[i] = -pi + 2.0 * pi * fraction;
    }

    /*
     * Correctness test.
     */
    sin_x87(input, x87_output, LENGTH);
    sin_stdlib(input, stdlib_output, LENGTH);

    double maximum_error = 0.0;

    for (uint64_t i = 0; i < LENGTH; i++) {
        double error = fabs(x87_output[i] - stdlib_output[i]);

        if (error > maximum_error) {
            maximum_error = error;
        }
    }

    printf("First five results:\n");

    for (uint64_t i = 0; i < 5; i++) {
        printf(
            "input = % .8f, x87 = % .15f, stdlib = % .15f\n",
            input[i],
            x87_output[i],
            stdlib_output[i]
        );
    }

    printf("\nMaximum absolute error: %.17g\n", maximum_error);

    /*
     * Timing test.
     *
     * Alternate the order so the same implementation does not always run
     * first.
     */
    double x87_total = 0.0;
    double stdlib_total = 0.0;

    for (int repeat = 0; repeat < REPEATS; repeat++) {
        if (repeat % 2 == 0) {
            x87_total += time_function(
                sin_x87,
                input,
                x87_output,
                LENGTH
            );

            stdlib_total += time_function(
                sin_stdlib,
                input,
                stdlib_output,
                LENGTH
            );
        } else {
            stdlib_total += time_function(
                sin_stdlib,
                input,
                stdlib_output,
                LENGTH
            );

            x87_total += time_function(
                sin_x87,
                input,
                x87_output,
                LENGTH
            );
        }
    }

    double x87_average = x87_total / REPEATS;
    double stdlib_average = stdlib_total / REPEATS;

    printf("\nAverage of %d runs:\n", REPEATS);
    printf("sin_x87:    %8.3f ms\n", x87_average * 1000.0);
    printf("sin_stdlib: %8.3f ms\n", stdlib_average * 1000.0);

    if (stdlib_average > 0.0) {
        printf(
            "x87 / stdlib time ratio: %.3f\n",
            x87_average / stdlib_average
        );
    }

    /*
     * Use the final results so the calculations cannot be discarded as
     * unused work.
     */
    printf(
        "Result checksum: %.17g\n",
        x87_output[LENGTH / 2] + stdlib_output[LENGTH / 2]
    );

    free(input);
    free(x87_output);
    free(stdlib_output);

    return 0;
}
