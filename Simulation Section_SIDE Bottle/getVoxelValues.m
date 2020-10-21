function [ voxels ] = getVoxelValues( v,f,resolution )
%% GETVOXELVALUES Takes vertices and generates a coordinate system to store the volume at a given point in the grid around the object
%==========================================================================
%
% USAGE
%       [ voxels ] = getVoxelValues( v,f,resolution ) 
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
%       voxels      - Mandatory - XxYxZx4 array     -The output of the function, given in the format of the meshgrid generated X coordinate values matrix, concatenated in the 4th dimension with the Y and Z location matrices, which are 3d, and finally with the 4th 4D dimension being the volume value on a scale of 0-1 at the coordinates given by the previous 3 values.
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
ranges = [range(fv.vertices(:,1)),range(fv.vertices(:,2)),range(fv.vertices(:,3))];
mins = min(v);
maxs = max(v);
%Scale based on resolution
voxInputs = floor(resolution/max(ranges)*ranges);
steps = ranges./voxInputs;
%% Use VOXELISE to get a logical array of voxels
OUT = VOXELISE(voxInputs(1),voxInputs(2),voxInputs(3),fv,'xyz');
%% Convert to points in 3D space and readjust to fit original geometry
%Set x y and z index values, and put in a vector
[voxelX, voxelY, voxelZ] = meshgrid(linspace((mins(1)+0.5*steps(1)),(maxs(1)-0.5*steps(1)),voxInputs(1)), ... 
                                    linspace((mins(2)+0.5*steps(2)),(maxs(2)-0.5*steps(2)),voxInputs(2)), ...
                                    linspace((mins(3)+0.5*steps(3)),(maxs(3)-0.5*steps(3)),voxInputs(3)));
voxels = cat(4,voxelX,voxelY,voxelZ,permute(OUT,[2 1 3]));
end