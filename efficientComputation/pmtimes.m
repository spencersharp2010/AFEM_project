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
function [result] = pmtimes(mat1,mat2,~)
%% Function documentation
%
% Computes pagewise matrix multiplication.
%
%  Input :
%   mat1 : The 3-d array of first operand matrices. The size( mat1 ) 
%          should be [nMat, m1, n1], where nMat is the number of matrices to
%          multiply and m1, n1 are the dimensions of each matrix
%   mat2 : The 3-d array of second operand matrices. The size( mat1 ) 
%          should be [nMat, m2, n2], where nMat is the number of matrices to
%          multiply and m2, n2 are the dimensions of each matrix
%
%          (of course n1 should be equal to m2)
%
% Output :
% result : The pagewise product of the input matrices. The size( result )
%          is [nMat, m1, n2]. For nMat, m1, n2, see input.
% 
%% Function main body

% do some error checking
size1 = size(mat1);
size2 = size(mat2);

if length(size1) == 2
    size1(3) = 1;
end
if length(size2) == 2
    size2(3) = 1;
end

if size1(3) ~= size2(2) || size1(1) ~= size2(1) || ...
        prod(size1) == 0 || prod(size2) == 0
    fprintf('error in matrix dimensions!\n');
    result = [];
    return;
else

% compute multiplication
result = bsxfun(@times,mat1(:, :, 1),mat2(:, 1, :));
for i = 2:size1(3);
    result = result + bsxfun(@times,mat1(:, :, i),mat2(:, i, :));
end

end


