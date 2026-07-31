#include <stdlib.h>
#include "lab11.h"
#include "version2/vectorclass.h"

double dot_double_vc(double* arr1, double* arr2, uint64_t n) {
    Vec4d total(0.0);

    for (uint64_t i = 0; i < n; i += 4) {
        Vec4d values1;
        Vec4d values2;

        values1.load(arr1 + i);
        values2.load(arr2 + i);

        total += values1 * values2;
    }

    return horizontal_add(total);
}

float dot_single_vc(float* arr1, float* arr2, uint64_t n) {
    Vec8f total(0.0f);

    for (uint64_t i = 0; i < n; i += 8) {
        Vec8f values1;
        Vec8f values2;
        
        values1.load(arr1 + i);
        values2.load(arr2 + i);

        total += values1 * values2;
    }
    return horizontal_add(total);
}

void map_poly_double_vc(double* input, double* output, uint64_t length, double a, double b, double c, double d) {
    Vec4d va(a);
    Vec4d vb(b);
    Vec4d vc(c);
    Vec4d vd(d);

    for (uint64_t i = 0; i < length; i+= 4) {
        Vec4d x;
        x.load(input + i);

        Vec4d result = ((va * x + vb) * x + vc) * x + vd;

        result.store(output + i);
    }
}

void map_poly_single_vc(float* input, float* output, uint64_t length, float a, float b, float c, float d) {
    Vec8f va(a);
    Vec8f vb(b);
    Vec8f vc(c);
    Vec8f vd(d);

    for (uint64_t i = 0; i < length; i+= 4) {
        Vec8f x;
        x.load(input + i);

        Vec8f result = ((va * x + vb) * x + vc) * x + vd;

        result.store(output + i);
    }

}