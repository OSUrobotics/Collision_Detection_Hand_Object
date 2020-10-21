function [ voxels ] = getVoxelisedVerts( v,f,resolution )
%GENERATETRANSLATIONVECTORS Takes a mesh and converts it to a voxel volume
%==========================================================================
%
% USAGE
%       [ voxels ] = getVoxelisedVerts( v,f,resolution ) 
%
% INPUTS
%
%       v           - Mandatory - Nx3 array         -List of a mesh's vertex coordinates where N is the number of verteces 
%
%       f           - Mandatory - Nx3 array         -List of that mesh's face data where N is the number of faces
%       
%       resolution  - Mandatory - Decimal value     -Value dictating the number of voxels along the maximum dimension of the mesh
%
% OUTPUTS
%
%       voxels      - Mandatory - Nx3 array         -List of voxels where N is the number of voxels and the 3 columns are their x, y, and z coordinates respectively
%
% EXAMPLE
%
%       To get the voxels of an STL file:
%       >>  [ voxels ] = getVoxelisedVerts( stlVerts, stlFaces, resolution )
%
% NOTES
%
%   -Mesh must be properly closed (ie. watertight)
% 
% REFERENCES
%
%   -This code uses VOXELISE by Adam A.
%=========================================================================


%% Add v and f to a struct to be passed to VOXELISE
fv.vertices = v;
fv.faces = f;
%% Prepare Dimensions for VOXELISE
%Calculate the dimensions of the object
dimRanges = [range(fv.vertices(:,1)),range(fv.vertices(:,2)),range(fv.vertices(:,3))];
%Scale based on resolution
voxInputs = floor(resolution/max(dimRanges)*dimRanges);
%% Use VOXELISE to get a logical array of voxels
OUT = VOXELISE(voxInputs(1),voxInputs(2),voxInputs(3),fv,'xyz');
%% Convert to points in 3D space and readjust to fit original geometry
%Set x y and z index values, and put in a vector
[xIndeces,yIndeces,zIndeces] = ind2sub(size(OUT),find(OUT));
indeces = [xIndeces,yIndeces,zIndeces];
%Move to a zero index
indeces = indeces -1;
%Convert verts back to their original scale
%% Get index ranges
indexRanges = range(indeces);
%% Devide the values by the ranges
indexRanges = repmat(indexRanges,size(indeces(:,1), 1),1);
indeces = indeces ./ indexRanges;
%% Multiply by the new scale and account for difference between center and edge of voxel
dimRanges = dimRanges - (max(dimRanges(:))/resolution)*2.1;
dimRanges = repmat(dimRanges,size(indeces(:,1), 1),1);
voxels = indeces .* dimRanges;
%% Center on orgin
voxels = translateMesh(voxels, [-1,0,0], range(xIndeces)/2);
voxels = translateMesh(voxels, [0,-1,0], range(yIndeces)/2);
voxels = translateMesh(voxels, [0,0,-1], range(zIndeces)/2);
%% Translate to object
center = getBBcenter(v);
thisCenter = getBBcenter(voxels);
difference = center - thisCenter;
voxels = translateMesh(voxels, difference, norm(difference));
end