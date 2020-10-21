function [ centroidPoint] = getCentroidMesh( pointList )
%GETCENTROIDMESH Gets the point to transform about, given a vertices matrix.
%   Takes the average of all the vertex values to get the centroid of a mesh.
centroidPoint = [mean(pointList(:,1)),mean(pointList(:,2)),mean(pointList(:,3))];
end

