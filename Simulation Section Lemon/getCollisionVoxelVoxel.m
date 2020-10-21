function [ amountCollide ] = getCollisionVoxelVoxel( handVox, objectSurfPoints, objectSurfaceArea, resolution, method)%, objectVox
%% GETCOLLISIONVOXELVOXEL Gets the amount of collisions between two voxel sets
% a set of voxels in both count and summed internal distance, given voxel coordinates Nx3 matrix, and a Nx4 matrix defining the SDF values at the meshgrid coordinates
%==========================================================================
%
% USAGE
%       [ amountCollide ] = getCollisionVoxelVoxel( handVox, objectVox, objectSurfPoints, objectSurfaceArea, resolution, method )
%
% INPUTS
%
%       handVox             - Mandatory - Nx4 array         - List of voxel data for the hand where the rows hold x,y,z values and a 1 or 0 for inside or outside, and where N is the number of points
%
%       objectVox           - Mandatory - Nx3 array         - List of the object's voxel coordinates where N is the number of voxels
%
%       objectSurfPoints    - Mandatory - Nx3 array         - List of the object's surface samples (Poisson disk sampling of points out of meshLab) where N is the number of points
%
%       objectSurfaceArea   - Mandatory - Double Value      - Total surface area of the object
%
%       resolution          - Mandatory - Double Value      - The resolution passed to getVoxelisedVerts when generating objectVox
%
%       method              - Mandatory - Interp3 Meathod   - The type of interpolation to use
%
% OUTPUTS
%
%       amountCollide       - Mandatory - Double Value      - Total collision value that represents the amount of the object inside the hand
%
% EXAMPLE
%
%       To get the collision of a pitcher with a BH8-280:
%       >>  [ amountCollide ] = getCollisionVoxelVoxel( BH8-280voxelValues, pitcherVoxelisedVerts, pitcherPoissonSamples, pitcherSurfaceArea, pitcherVoxelisedVertsResolution, 'cubic' )
%
% NOTES
%
%   -Both meshes must be properly closed (ie. watertight).
%   -objectSurfPoints must match the mesh used to generate objectVox.
%   -The resolution value must match the one passed to getVoxelisedVerts 
%    to get the voxel data for the object.
%
%==========================================================================

% valuesAtVoxels = interp3(handVox(:,:,:,1),handVox(:,:,:,2),handVox(:,:,:,3),handVox(:,:,:,4),objectVox(:,1),objectVox(:,2),objectVox(:,3),method);
%% Filter by only inside
% valuesAtVoxels = valuesAtVoxels(valuesAtVoxels>0.5);
% disp("GOING IN" + valuesAtVoxels);
%% Same for objectSurfPoints
valuesAtSurf = interp3(handVox(:,:,:,1),handVox(:,:,:,2),handVox(:,:,:,3),handVox(:,:,:,4),objectSurfPoints(:,1),objectSurfPoints(:,2),objectSurfPoints(:,3),method);
%% Filter by only inside
valuesAtSurf = valuesAtSurf(valuesAtSurf>0.5);
%% Get areaPerVoxel
%Get max dimension of bounding box
% maxRange = max([range(objectSurfPoints(:,1)),range(objectSurfPoints(:,2)),range(objectSurfPoints(:,3))]);
%Devide size by number of voxels, and then cube that to get area per voxel
% volumePerVoxel = (maxRange / resolution)^3;

%% Get areaPerSurfPoint
%Get surface area per point
surfAreaPerPoint = objectSurfaceArea / size(objectSurfPoints,1);
%Covert to a volume
volumePerPoint = surfAreaPerPoint * (sqrt(surfAreaPerPoint));
%Devide by two to compensate for edge-ness
volumePerPoint = (volumePerPoint / 2);

%% Add values together
amountCollide =   length(valuesAtSurf) * volumePerPoint; %length(valuesAtVoxels) * volumePerVoxel;%length(valuesAtSurf) * volumePerPoint +
end

