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
function K = computeStiffnessMatrixPlateInMembraneActionLinear(mesh,materialProperties,analysis)
%% Function documentation
%
% Computes the stiffness matrix needed for linear analysis of a plate in
% membrane action
%
%              Input :
%               mesh : The mesh of the structure
% materialProperties : The material properties of the structure
%           analysis : Analysis type (plane stress or plane strain)
%
%             Output :
%                  K : Master stiffness matrix
%
% Function layout :
%
% 0. Read input
%
% 1. Loop over all elements
%
% 2. Check the rigid body modes of the master stiffness matrix
%
%% Function main body

%% 0. Read input

% Number of nodes for the global system
no_nodes_global = length(mesh.nodes);

% Number of degrees of freedom for the global system
if strcmp(analysis.dimension,'2d')&&strcmp(analysis.dofs,'displacements')
    no_dofs_global = 2*no_nodes_global;
end

% Number of DoFs at the element level (depends on the element type)
no_nodes_element = 3;
no_dofs_element = no_nodes_element*2;

% Initialize master stiffness matrix
K = zeros(no_dofs_global,no_dofs_global);

%% 1. Loop over all elements
for i=1:length(mesh.elements)
    
    % Get the current element in the mesh
    element = mesh.elements(i,:);
    
    % Get the nodes of the triangle in a counterclockwise fashion
    nodes = mesh.nodes(element,:);
    
    % Compute element stiffness matrix for the CST
    K_element = computeElementStiffnessMatrixPlateInMembraneActionLinearCST(nodes,materialProperties,analysis);
    
    % Assemble to the global stiffness matrix via element freedom tables
    
    % Element freedom table
    EFT = zeros(1,no_dofs_element);
    
    % Assign the entried of the element freedom table recursively
    for j=1:no_nodes_element
        EFT(1,2*j-1) = 2*element(j)-1;
        EFT(1,2*j) = 2*element(j);
    end
    
    K(EFT,EFT) = K(EFT,EFT) + K_element;  
end

%% 2. Check the rigid body modes of the master stiffness matrix

% Compute rank and size of the master stiffness matrix
[sizeK,~] = size(K);
rankK = rank(K);

rigid_body_modes = sizeK - rankK;

% For plane analysis the rigid body modes must be 3: 2 translatoric and one
% rotational modes. Otherwise print warning message
if rigid_body_modes~=3
   fprintf('Warning: Master stiffness matrix has %d rigid body modes',rigid_body_modes); 
end

end

