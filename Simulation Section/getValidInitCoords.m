function getValidInitCoords()

    shapeFiles = ["shape_meshes/CubeS.stl", "shape_meshes/CubeM.stl","shape_meshes/CubeB.stl","shape_meshes/CylinderS.stl","shape_meshes/CylinderM.stl","shape_meshes/CylinderB.stl"];
    objSurfAreas = [147.852005, 200.401337, 260.403015, 16694.800781, 23090.662109, 30490.078125];
    %poissonFiles = ["CubeS.stl","CubeM.stl","CubeB.stl","CylinderS.stl","CylinderM.stl","CylinderB.stl"];
    
    % Resolution determined from previous study - shpaes made with
    % resolution 25
    resolution = 25;
    
    % Range of area of possible starting object position coordinates
    xMin = -0.075;
    xMax = 0.075;
    yMin = 0.0;
    yMax = 0.07;
    
    % Number of initial starting position coordinates
    numCoords = 50;
    
    for i = 1:length(shapeFiles)
       disp(shapeFiles(i));
       xCoords = xMin + (xMax-xMin).*rand(numCoords,1);
       yCoords = yMin + (yMax-yMin).*rand(numCoords,1);
       zCoords = zeros(numCoords); % CHANGE THIS --> half size of object height
       %disp("xCoordsare");
       %disp(xCoords);
       % Get the stl file, object poisson points, surface area
       [objVerts, objFaces, objNormals, objName] = stlRead(shapeFiles(i));
       poissonFilename = erase(shapeFiles(i),".stl") + "_poisson.ply";
       objectSurfPoints = read_ply(poissonFilename);
       objectSurfaceArea = objSurfAreas(i);
 
       % Used for displaying the points
       ptCloud = pointCloud(objectSurfPoints)
       filename = "Coords"+i+".txt";
       if exist(filename, 'file') == 2
        delete(filename);
       end        
       % numCoords --> number of starting positions to generate for each
       % shape
       for j = 1:numCoords
           % Translate X values (vertices, axis, transform distance)
           objVerts = translateMesh( objVerts, [1,0,0], xCoords(j));
           % Translate Y values
           objVerts = translateMesh( objVerts, [0,1,0], yCoords(j));
           
           disp("New objVerts: ");
           disp(objVerts(1,:));
           
           % Poisson: Translate X values (vertices, axis, transform distance)
           objectSurfPoints = translateMesh( objectSurfPoints, [1,0,0], xCoords(j));
           % Poisson: Translate Y values
           objectSurfPoints = translateMesh( objectSurfPoints, [0,1,0], yCoords(j));
           
           % Get the amount of collision based on object and hand
           amountCollide = getCollisionFromSTL(objVerts, objFaces, objectSurfPoints, objectSurfaceArea, resolution);
           %disp("objectSurfPoints: ");
           %disp(objectSurfPoints);
           
%            pcwrite(ptCloud,'object3d.pcd','Encoding','ascii');
%            pc = pcread('object3d.pcd');
           %pcshow(pc);
           
%            ptCloudtransformed = pointCloud(objectSurfPoints)
%            pcwrite(ptCloudtransformed,'object3dtrans.pcd','Encoding','ascii');
%            pct = pcread('object3dtrans.pcd');
           %pcshowpair(pc,pct);
           
           % Add: accept or reject point
           if (amountCollide == 0)
                fid = fopen(filename,'at');
                fprintf(fid, '%f %f %f\n', xCoords(j), yCoords(j), zCoords(j));
                fclose(fid);               
           end
       end
    end
    
    
end