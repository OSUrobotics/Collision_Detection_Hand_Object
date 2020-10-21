function [ verticesOut ] = translateMesh( verticesIn, directionVector, distanceTransform )
%% TRANSLATEMESH Translates a set of verteces along a vector a set distance
%==========================================================================
% 
% USAGE
%       [ verticesOut ] = translateMesh( verticesIn, directionVector, distanceTransform )
%
% INPUTS
%
%       verticesIn          - Mandatory - Nx3 array     -List of vertices where N is the number of vertices 
%       
%       directionVector     - Mandatory - 1x3 array     -Vector to translate along
%       
%       distanceTransform   - Optional  - Single value  -Number of units to move along the directionVector
%
% OUTPUTS
%
%       verticesOut     - Mandatory - Nx3 array     -List of verteces where N is the number of vertices in.
%
% EXAMPLE
%
%       To translate an stl file 10 units on the z axis:
%       >>  stlVerts = translateMesh( stlVerts, [0,0,1], 10 )
%
%       To get a new set of verts that is translated 12 units on the x axis:
%       >>  newVerts = translateMesh( oldVerts, [1,0,0], 12 )
%
% NOTES
%
%   -If input vector is not a unit vector, it will be normalized internaly
%==========================================================================
if nargin == 3
    directionVector = directionVector/norm(directionVector)*distanceTransform;
end
verticesOut = bsxfun(@plus,verticesIn,directionVector);
end