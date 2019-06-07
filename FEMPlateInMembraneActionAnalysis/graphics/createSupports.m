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
%   Prof. Dr.-Ing. Kai-Uwe Bletzinger  (kub@tum.de)                       %
%   Dr.-Ing. Roland Wüchner            (wuechner@tum.de)                  %
%   _______________________________________________________________       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xs,ys,zs] = createSupports(nodes,rb)
%% Function documentation
%
% returns coordinates for the triangles at the support locations
%
%   Input : 
%   nodes : The nodes of the mesh
%      rd : Array containing information on the supports
%
%  Output :
%      xs : x-coordinates of the support triangle vertices
%      ys : y-coordinates of the support triangle vertices
%      zs : z-coordinates of the support triangle vertices
%
%% Function main body

% scaling factors for the support triangles
up = max(max(max(nodes)));
lo = min(min(min(nodes)));

% Average the factor with respect to the maximum and minimum values 
fac = (up-lo)/5;

% Initialize the output arrays
xs = zeros(length(rb),4);
ys = zeros(length(rb),4);
zs = zeros(length(rb),4);

for k = 1:length(rb)
    % Get the corresponding Control Point number p and indices node(k)
    h=rb(k)/2;
    p=ceil(h);

    %(rb is odd -> horizontal support)
    if p~=h   
        xs(k,1)=nodes(p,1);
        xs(k,2)=nodes(p,1)-0.1732*fac;
        xs(k,3)=nodes(p,1)-0.1732*fac;
        xs(k,4)=xs(k,1);
        ys(k,1)=nodes(p,2);
        ys(k,2)=nodes(p,2)+0.1*fac;
        ys(k,3)=nodes(p,2)-0.1*fac;
        ys(k,4)=ys(k,1);
        zs(k,1:4)=nodes(p,3);
        
    %(rb is even -> vertical support)
    else        
        xs(k,1)=nodes(p,1);
        xs(k,2)=nodes(p,1)-0.1*fac;
        xs(k,3)=nodes(p,1)+0.1*fac;
        xs(k,4)=xs(k,1);
        ys(k,1)=nodes(p,2);
        ys(k,2)=nodes(p,2)-0.1732*fac;
        ys(k,3)=nodes(p,2)-0.1732*fac;
        ys(k,4)=ys(k,1);
        zs(k,1:4)=nodes(p,3);
    end
end

end