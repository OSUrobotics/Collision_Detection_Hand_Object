function getValidInitCoords()
    B_Height = 1;
    M_Height = 0.9166;
    S_Height = 0.8333;
    B_Width = 1;
    M_Width = 0.85;
    S_Width = 0.7;
    
    scale_fact_cube = 0.01043;
    scale_fact_cyl = 0.001;
    object_size = M_Height; %HEIGHT SCALE
    object_width = M_Width; %WIDTH SCALE
    scale_fact = scale_fact_cyl;
    
    folder = "shape_meshes/Large_Shapes/";
    shapeFiles = ["CubeB.stl", "CylinderB.stl", "CubeB45.stl", "Cone1B.stl", "Cone2B.stl", "Vase1B.stl", "Vase2B.stl"];
    objSurfAreas = [260.403015, 30490.078125, 26041.628906, 38936.878906, 33730.628906, 20662.521484, 29315.062500];
    
    % Resolution determined from previous study - shpaes made with
    resolution = 25;
    
    % Range of area of possible starting object position coordinates
    xMin = -0.075;
    xMax = 0.075; 
    yMin = 0.0;
    yMax = 0.07;
    
    %get polygon coordinates form range
    xv = [xMin;xMax;0.0;xMin];
    yv = [yMin;yMin;yMax;yMin];
    
    % Number of initial starting position coordinates
    numCoords = 1;
    num_correct_vals = 5000;

    
    for i = 1:length(shapeFiles)
%        disp(shapeFiles(i));

       zCoords = ones(numCoords,1)*0.0654; 
       %disp("Coordsare");
       
%        disp(folder+shapeFiles(i));
       % Get the stl file, object poisson points, surface area
       [objVerts, objFaces, objNormals, objName] = stlRead(folder+shapeFiles(i));
       
%        disp(objVerts);
        if (i==1)
            scale_fact = scale_fact_cube;
        end
        
        scale_obj = makehgtform('scale',[scale_fact*object_width, scale_fact*object_width, scale_fact*object_size]);
        M = scale_obj;
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        verts = M*verts;
        verts = verts';
        objVerts = verts(:, 1:3);
        
        %scale surfaceareas of objects as well
        objSurfAreas(i) = scale_fact*scale_fact*objSurfAreas(i);
       
       % Translate Z values 
       objVerts1 = translateMesh( objVerts, [0,0,1], zCoords);
       
       poissonFilename = folder + erase(shapeFiles(i),".stl") + ".ply";
%        disp(poissonFilename);
       objectSurfPoints = read_ply(poissonFilename);
       objectSurfPoints = scale_fact*objectSurfPoints;
%         disp(objectSurfPoints);
       objectSurfaceArea = objSurfAreas(i);
 
       % Used for displaying the points
       %ptCloud = pointCloud(objectSurfPoints);
       filename = "Coords_try"+i+".txt";
       if exist(filename, 'file') == 2
        delete(filename);
       end        
       % numCoords --> number of starting positions to generate for each
       % shape
       j = 1;
       while(j<=num_correct_vals)
       %--->for j = 1:numCoords
           xCoords = xMin + (xMax-xMin).*rand(numCoords,1);
           yCoords = yMin + (yMax-yMin).*rand(numCoords,1);
           
           if (inpolygon(xCoords,yCoords,xv,yv) == 0)
               disp("NOT IN RANGE");
               continue;
           end
           % Translate X values (vertices, axis, transform distance)
           objVerts2 = translateMesh( objVerts1, [1,0,0], xCoords);
           % Translate Y values
           objVerts3 = translateMesh( objVerts2, [0,1,0], yCoords);
           
           % Poisson: Translate X values (vertices, axis, transform distance)
           objectSurfPoints1 = translateMesh( objectSurfPoints, [1,0,0], xCoords);
           % Poisson: Translate Y values
           objectSurfPoints2 = translateMesh( objectSurfPoints1, [0,1,0], yCoords);
           % Poisson: Translate Z values
           objectSurfPoints3 = translateMesh( objectSurfPoints2, [0,0,1], zCoords);           
           % Get the amount of collision based on object and hand
           [amountCollide, handFaces, handVerts] = getCollisionFromSTL(objVerts3, objFaces, objectSurfPoints3, objectSurfaceArea, resolution);
           
           % Accept or reject point
           if (amountCollide == 0)  
                fid = fopen(filename,'at');
                fprintf(fid, '%f %f %f\n', xCoords, yCoords, zCoords);
                fclose(fid); 
                disp(j);
                j=j+1;
%                 axis equal
%                 hold on;
%                 plot3([0,0], [0,0.1],[0,0], '-g', [0,0.1], [0,0],[0,0], '-r', [0,0], [0,0],[0,0.1], '-c');
%                 patch('Faces',[objFaces;handFaces],'Vertices',[objVerts3;handVerts],'FaceColor','red');

           end
       end
    end
end


%%%%%%%%%%TO DISPLAY OBJECT POINT CLOUD           
%            pcwrite(ptCloud,'object3d.pcd','Encoding','ascii');
%            pc = pcread('object3d.pcd');
           %pcshow(pc);
           
%            ptCloudtransformed = pointCloud(objectSurfPoints)
%            pcwrite(ptCloudtransformed,'object3dtrans.pcd','Encoding','ascii');
%            pct = pcread('object3dtrans.pcd');
           %pcshowpair(pc,pct);