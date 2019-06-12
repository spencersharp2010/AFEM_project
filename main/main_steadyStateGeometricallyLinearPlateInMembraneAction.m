%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _______________________________________________________               %
%   _______________________________________________________               %
%                                                                         %
%   Technische Universität München                                        %
%   Lehrstuhl für Statik, Prof. Dr.-Ing. Kai-Uwe Bletzinger               %
%   _______________________________________________________               %
%   _______________________________________________________               %
%                                                                         %
%                                                                         %
%   Authors                                                               %
%   _______________________________________________________________       %
%                                                                         %
%   Dipl.-Math. Andreas Apostolatos    (andreas.apostolatos@tum.de)       %
%   Dr.-Ing. Roland Wüchner            (wuechner@tum.de)                  %
%   Prof. Dr.-Ing. Kai-Uwe Bletzinger  (kub@tum.de)                       %
%   _______________________________________________________________       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script documentation
%
% Task : Plane stress analysis for a rectangular plate subject to uniform
%        pressure on its top edge
%
% Date : 19.02.2014
%
%% Preamble
clear;
clc;
close all;

%% Includes

% Add general math functions
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/generalMath/');

% Add all functions related to parsing
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/parsers/');

% Add all functions related to the low order basis functions
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/basisFunctions/');

% Add all equation system solvers
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/equationSystemSolvers/');

% Add all the efficient computation functions
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/efficientComputation/');

% Add all functions related to plate in membrane action analysis
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/solvers/',...
        'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/solutionMatricesAndVectors/',...
        'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/loads/',...
        'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/graphics/',...
        'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/output/',...
        'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/postprocessing/',...
        'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/FEMPlateInMembraneActionAnalysis/errorComputation/');
    
% Include performance optimzed functions
addpath('C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/efficientComputation/');

%% Parse data from GiD input file

% Define the path to the case
pathToCase = 'C:/Users/spenc/Documents/MATLAB/group1_sensitivityAnalysisFEMLinearElasticity/inputGiD/FEMPlateInMembraneActionAnalysis/';
% caseName = 'cantileverBeamPlaneStress';
% caseName = 'group1';
caseName = 'test_case6';
% Parse the data from the GiD input file
[strMsh,homDBC,inhomDBC,valuesInhomDBC,NBC,analysis,parameters,...
    propNLinearAnalysis,propStrDynamics] = ...
    parse_StructuralModelFromGid(pathToCase,caseName,'outputEnabled');

%% GUI

% On the body forces
bodyForces = @computeConstantVerticalBodyForceVct;

% Choose equation system solver
solve_LinearSystem = @solve_LinearSystemMatlabBackslashSolver;
% solve_LinearSystem = solve_LinearSystemGMResWithIncompleteLUPreconditioning;

% Choose computation of the stiffness matrix (CST = constant strain
% triangle)
computeStiffMtxLoadVct = @computeStiffMtxAndLoadVctFEMPlateInMembraneActionCST;
% computeStiffMtxLoadVct = @computeStiffMtxAndLoadVctFEMPlateInMembraneActionMixed;

% Quadrature for the stiffness matrix and the load vector of the problem
% 'default', 'user'
intLoad.type = 'default';
intDomain.type = 'default';
intLoad.noGP = 1;
intDomain.noGP = 1;

% Quadrature for the L2-norm of the error
intError.type = 'user';
intError.noGP = 4;

% Linear analysis
propStrDynamics = 'undefined';

% On whether the case is a unit test
isUnitTest = false;

% Initialize graphics index
graph.index = 1;

%% Output data to a VTK format
pathToOutput = '../outputVTK/FEMPlateInMembraneActionAnalysis/';

% %% Compute the load vector
t = 0;
F = computeLoadVctFEMPlateInMembraneAction(strMsh,analysis,NBC,t,intLoad,'outputEnabled');
% 
% %% Visualization of the configuration
graph.index = plot_referenceConfigurationFEMPlateInMembraneAction...
     (strMsh,analysis,F,homDBC,graph,'outputEnabled');

%% Solve the plate in membrane action problem
[dHat,FComplete,minElSize] = solve_FEMPlateInMembraneAction...
    (analysis,strMsh,homDBC,inhomDBC,valuesInhomDBC,NBC,bodyForces,...
    parameters,computeStiffMtxLoadVct,solve_LinearSystem,...
    propNLinearAnalysis,propStrDynamics,intDomain,caseName,pathToOutput,...
    isUnitTest,'outputEnabled');

%% Postprocessing
% graph.visualization.geometry = 'reference_and_current';
% resultant = 'stress';
% component = 'y';
% graph.index = plot_currentConfigurationAndResultants(strMsh,homDBC,dHat,parameters,analysis,resultant,component,graph);

% Compute the error in the L2-norm for the case of the plane stress
% analysis over a quarter annulus plate subject to tip shear force
if strcmp(caseName,'unitTest_curvedPlateTipShearPlaneStress')
    nodeNeumann = strMsh.nodes(NBC.nodes(1,1),:);
    funHandle = str2func(NBC.fctHandle(1,:));
    forceAmplitude = norm(funHandle(nodeNeumann(1,1),nodeNeumann(1,2),nodeNeumann(1,3),0));
    internalRadius = 4;
    externalRadius = 5;
    propError.resultant = 'displacement';
    propError.component = '2norm';
    errorL2 = computeRelErrorL2CurvedBeamTipShearFEMPlateInMembraneAction...
        (strMsh,dHat,parameters,internalRadius,externalRadius,forceAmplitude,...
        propError,intError,'outputEnabled');
end

%% END OF THE SCRIPT
