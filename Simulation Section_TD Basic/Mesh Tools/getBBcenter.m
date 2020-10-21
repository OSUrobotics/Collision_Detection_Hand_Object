function [ centerPoint ] = getBBcenter( pointList )
%GETBBCENTER Gets the center of the object by taking the outer bounds and averaging them
centerPoint = [(max(pointList(:,1))+min(pointList(:,1)))/2,(max(pointList(:,2))+min(pointList(:,2)))/2,(max(pointList(:,3))+min(pointList(:,3)))/2];
end