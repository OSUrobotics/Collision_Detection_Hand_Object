function [ verticesOut ] = rotateMesh( verticesIn, normalVector, theta, centroid )
%% ROTATEMESH Rotates a set of verteces around a vector theta degrees
%==========================================================================
% 
% USAGE
%       [ verticesOut ] = rotateMesh( verticesIn, normalVector, theta, centroid )
%
% INPUTS
%
%       verticesIn      - Mandatory - Nx3 array     -List of verteces where N is the number of verteces 
%       
%       normalVector    - Mandatory - 1x3 array     -Vector to rotate around
%       
%       theta           - Mandatory - Single value  -Number of degrees to rotate around the normalVector
%
%       centroid        - Optional  - 1x3 array     -Point that represents the center of rotation
%
% OUTPUTS
%
%       verticesOut     - Mandatory - Nx3 array     -List of verteces where N is the number of verteces in.
%
% EXAMPLE
%
%       To rotate an stl file 90 degrees on the z axis:
%       >>  stlVerts = rotateMesh( stlVerts, [0,0,1], 90 )
%
%       To get a new set of verts that is rotated 78 degrees on the x axis around a specified point:
%       >>  newVerts = rotateMesh( oldVerts, [1,0,0], 78, rotationPoint )
%
% NOTES
%
%   -If input vector is not a unit vector, it will be normalized internaly
%==========================================================================

%% Standardizing passed in contents if not in desired format
if nargin == 3 % if there isn't a given center, make it the centroid
    centroid = getCentroidMesh(verticesIn);
end
normalVector = normalVector/norm(normalVector); % convert the normal vector into a unit vector
%% Conditionally either rotate or move, rotate, and move the points
if centroid == 0 % if don't need to relocate center to origin before rotating
    verticesOut = quatrotate([sind(theta/2),normalVector(:)'],verticesIn); % apply the quaternion rotation
else % if center and origin don't overlap
    verticesIn = bsxfun(@minus,verticesIn,centroid); % move center to origin and transpose matrix
    verticesOut = quatrotate([sind(theta/2),normalVector(:)'],verticesIn); % apply the quaternion rotation
    verticesOut = bsxfun(@plus,verticesOut,centroid); % move center back to original place
end
end