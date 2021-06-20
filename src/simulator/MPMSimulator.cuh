//
// Created by jiaruiyan on 5/26/21.
//

#ifndef JIARUI_MPM_MPMSIMULATOR_H
#define JIARUI_MPM_MPMSIMULATOR_H

#include <vector>
#include <array>
#include <cuda_runtime.h>
#include <iostream>
#include <glm.hpp>
#include "material/Elasiticity.cuh"

class MeshObject;
class FixedCorotatedMaterial;

// In 3D
/*
struct ParticleGroup{
    unsigned int particleNum;
    std::vector<FixedCorotatedMaterial> mMaterialVec; // It may needs to be changed to a vector in the future.
    std::vector<double> particlePosVec;
    std::vector<double> particleMassVec;
    std::vector<double> particleVelVec;
    std::vector<double> particleVolVec;
    std::vector<unsigned int> particleNumDiv;
    double* pPosVecGRAM;
    double* pMassVecGRAM;
    double* pVelVecGRAM;
    double* pVolVecGRAM;
    double* pElasiticityDeformationGradientGRAM;
    double* pPlasiticityDeformationGradientGRAM;
    double* pAffineVelGRAM;
    double* pDeformationGradientDiffGRAM;
    int* pParticleNumDivGRAM;
    int* pParticleTypeGRAM;
    double* pLambda0GRAM;
    double* pMu0GRAM;
    size_t posVecByteSize;
    size_t massVecByteSize;
    size_t velVecByteSize;
    size_t volVecByteSize;
    size_t dgVecByteSize;
    size_t affineVelVecByteSize;
    size_t dgDiffVecByteSize;
};
*/

struct ObjInitInfo{
    std::array<double, 3> initVel;
    glm::vec3 initTranslation;
    glm::vec3 initRotationAxis;
    glm::vec3 initScale;
    float initRotationDegree;
    std::string objPath;
    Material mMaterial;
};


struct ParticleGroup{
    unsigned int particleNum;
    double mParticleMass;
    double mParticleVolume;
    Material mMaterial;
    std::vector<double> particlePosVec;

    double* pPosVecGRAM;
    double* pVelVecGRAM;
    double* pElasiticityDeformationGradientGRAM;
    double* pPlasiticityDeformationGradientGRAM;
    double* pAffineVelGRAM;
    double* pDeformationGradientDiffGRAM;

    size_t posVecByteSize;
    size_t velVecByteSize;
    size_t eDgVecByteSize;
    size_t pDgVecByteSize;
    size_t affineVelVecByteSize;
    size_t dgDiffVecByteSize;
};

struct Grid{
    double h;
    unsigned int nodeNumDim; // The number of node for each dimension. We assume the grid is a cube.
    std::array<double, 3> originCorner;
    double* nodeMassVec;
    double* nodeVelVec;
    double* nodeForceVec; // Elastic force now.
    size_t massVecByteSize;
    size_t velVecByteSize;
    size_t forceVecByteSize;
};

class MPMSimulator {
private:
    // Debug:
    std::vector<int> idx_vec;
    double max_dt;
    double ext_gravity;

    double min_bound_x;
    double min_bound_y;
    double min_bound_z;
    double max_bound_x;
    double max_bound_y;
    double max_bound_z;

    void initGrid(double gap, unsigned int nodeNumDim);
    double calVolmue(std::string& place);
    void showMemUsage();
    void initParticles(ParticleGroup& initPG, ObjInitInfo& initObjInfo);

public:
    double adp_dt;
    double current_time;
    int current_frame;

    // ParticleGroup mParticles{};
    std::vector<ParticleGroup> mParticlesGroupsVec;
    Grid mGrid{};

    MPMSimulator(double gap,
                 double dt,
                 unsigned int nodeNumDim,
                 unsigned int particleNumPerCell,
                 std::vector<ObjInitInfo>& objInitInfoVec);

    void step();
    int totalParticlesNum();
    void getGLParticlesPos(std::vector<float>& oPosVec);
    ~MPMSimulator();
};


#endif //JIARUI_MPM_MPMSIMULATOR_H
