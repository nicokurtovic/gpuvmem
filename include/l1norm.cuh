#ifndef L1NORM_CUH
#define L1NORM_CUH

#include "framework.cuh"
#include "functions.cuh"


class L1norm : public Fi
{
public:
L1norm();
float calcFi(float *p);
void calcGi(float *p, float *xi);
void restartDGi();
void addToDphi(float *device_dphi);
void configure(int penalizatorIndex, int imageIndex, int imageToAdd);
void setSandDs(float *S, float *Ds);
float calculateSecondDerivate(){
};
};

#endif
