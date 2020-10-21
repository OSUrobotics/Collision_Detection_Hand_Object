%%%%%%%%%%%%TO CHANGE:
% CHANGE SIZE:
% Change object size and width (line 12 and 13)
% Change translation (line 56)

% CHANGE SHAPE:
% Change object size and width (line 12 and 13)
% Change scale_fact (line 24)
% Change file name (line 29-30)
% Change surface area (line 31)
% If cube, uncomment (line 58-61)

function getValidInitCoords()
    B_Height = 1;
    M_Height = 0.9166;
    S_Height = 0.8333;
    B_Width = 1;
    M_Width = 0.85;
    S_Width = 0.7;
    hand_loc = 0;
    filename = "";
    
    scale_fact_cube = 0.01043;
    scale_fact_cyl = 0.001;
    object_size = M_Height; %HEIGHT SCALE
    object_width = M_Width; %WIDTH SCALE
    scale_fact =  0.0004;%---->0.00118;
    
    folder = "shape_meshes/Nigel_Large_Shapes/";
    shapeFiles = ["ShortBottle.STL", "ShortBottle.STL", "ShortBottle.STL"];%["CubeB.stl", "CylinderB.stl", "CubeB45.stl", "Cone1B.stl", "Cone2B.stl", "Vase1B.stl", "Vase2B.stl"];
    objSurfAreas = [235880.000000, 235880.000000, 235880.000000];%[260.403015, 30490.078125, 26041.628906, 38936.878906, 33730.628906, 20662.521484, 29315.062500]; 
    
    % Resolution determined from previous study - shpaes made with
    resolution = 25;
    
    % Range of area of possible starting object position coordinates
    %NORMAL GRASP
%     xMin = -0.08;
%     xMax = 0.08; 
%     yMin = 0.0;
%     yMax = 0.07;
%     %get polygon coordinates form range
%     xv = [xMin;xMax;0.0;xMin];
%     yv = [yMin;yMin;yMax;yMin];
        

   %SIDE TILTED GRASP Short Bottle
    xMin = 0.015;
    yMid1 = 0.09;
    xMax = 0.08; 
    yMin = 0.021;
    yMax = 0.11;
    yMid2 = 0.045;
    
    %get polygon coordinates form range
    xv = [xMin;xMin;xMax;xMax;xMin];
    yv = [yMid1;yMid2;yMin;yMax;yMid1];
    
    % Number of initial starting position coordinates
    numCoords = 1;
    num_correct_vals = 5000;

    
    for i = 1:length(shapeFiles)
%        disp(shapeFiles(i));

       zCoords = ones(numCoords,1)*0.0;%smalltd0.042;%0.0654; 

       % Get the stl file, object poisson points, surface area
       [objVerts, objFaces, objNormals, objName] = stlRead(folder+shapeFiles(i));

%%%%%%%%%%%%% UNCOMMENT  WHEN USING CUBE
%         if (i==1)
%             scale_fact = scale_fact_cube;
%         else
%             scale_fact = scale_fact_cyl;
%         end
        

%         tra_obj = makehgtform('translate', [-0.2345,0.03457, -0.01941]);
%         hand_loc = [0.00201475 -0.00653648  0.21715879];
%         filename = "Coords_TD_ShortBottleM.txt";
        
        if (i==1)
            object_size = M_Height; 
            object_width = M_Width; 
            tra_obj = makehgtform('translate', [-0.2345,0.03457,-0.01941]);
            hand_loc =  [-0.00024876  0.0579915  0.1984];%0.13605835];
            filename = "Coords_ST_BottleM.txt";
            tryfid = fopen("../../rotated_hands/additional_shapes/Bottle"+"M_side_rotation.txt");
            tryformat = "%f";
            sizeA = [3 num_correct_vals];
            A = fscanf(tryfid,tryformat, sizeA);
            A = A';
            j = 1;
            hand_rot = A(j,:);
            
        elseif (i==2)
            object_size = B_Height; 
            object_width = B_Width; 
            tra_obj = makehgtform('translate', [-0.2759,  0.04067, -0.02116]);
            hand_loc = [-0.00024876  0.0579915  0.2165];%0.15486631];%0.22927994];
            filename = "Coords_ST_BottleB.txt";
            tryfid = fopen("../../rotated_hands/additional_shapes/Bottle"+"B_side_rotation.txt");
            tryformat = "%f";
            sizeA = [3 num_correct_vals];
            A = fscanf(tryfid,tryformat, sizeA);
            A = A';
            j = 1;
            hand_rot = A(j,:);
            
        elseif (i==3)
            object_size = S_Height; 
            object_width = S_Width; 
            tra_obj = makehgtform('translate', [-0.1931,0.02847,-0.0176]);
            hand_loc = [-0.00024876  0.0579915  0.1804];%0.11725039];
            filename = "Coords_ST_BottleS.txt";
            tryfid = fopen("../../rotated_hands/additional_shapes/Bottle"+"S_side_rotation.txt");
            tryformat = "%f";
            sizeA = [3 num_correct_vals];
            A = fscanf(tryfid,tryformat, sizeA);
            A = A';
            j = 1;
            hand_rot = A(j,:);
        
        else
            disp("ERROR");
        end
            
        scale_obj = makehgtform('scale',[scale_fact*object_width, scale_fact*object_size, scale_fact*object_width]);
        rot_obj = makehgtform('xrotate',pi/2);            
%         disp("transforms object");
%         disp(tra_obj);
        M = tra_obj*rot_obj*scale_obj;
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
       
       poissonFilename = folder + erase(shapeFiles(i),".STL") + ".ply";
       objectSurfPoints = read_ply(poissonFilename);
%        objectSurfPoints = scale_fact*objectSurfPoints;
%         scale_pts = makehgtform('scale',[scale_fact*object_width, scale_fact*object_width, scale_fact*object_size]);
%         rot_pts = makehgtform('xrotate',0);
%         tra_pts = makehgtform('translate',[0,0,0]);
        M_pts = tra_obj*rot_obj*scale_obj;%tra_pts*rot_pts*scale_pts;
        verts_pts = objectSurfPoints;
        verts_pts(:,4)  = 1;
        verts_pts = verts_pts';
        verts_pts = M_pts*verts_pts;
        verts_pts = verts_pts';
        objectSurfPoints = verts_pts(:, 1:3);
%        disp("LOOK HERE:" + max(objectSurfPoints(:,1))+" "+ max(objectSurfPoints(:,2))+" "+ max(objectSurfPoints(:,3)));
%        disp("FILE" + length(shapeFiles));
       objectSurfaceArea = objSurfAreas(i);


       
       if exist(filename, 'file') == 2
        delete(filename);
       end        

       j = 1;
       while(j<=num_correct_vals)
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
%            disp(objectSurfPoints3(:,1));
                          

           % Get the amount of collision based on object and hand
           [amountCollide, handFaces, handVerts] = getCollisionFromSTL(objVerts3, objFaces, objectSurfPoints3, objectSurfaceArea, resolution, hand_loc, hand_rot);           
           % Accept or reject point
           if (amountCollide == 0)  
                fid = fopen(filename,'at');
                fprintf(fid, '%f %f %f\n', yCoords, -xCoords, zCoords);
                fclose(fid); 
                disp(j);
                hand_rot = A(j,:);
%                 disp(hand_rot);
                j=j+1;

% %                 disp(xCoords);
% %                 disp(yCoords);
% %                 disp(zCoords);
% % 
%                 axis equal
% %                 hold on;
% %                 plot3([0,0], [0,0.1],[0,0], '-g', [0,0.1], [0,0],[0,0], '-r', [0,0], [0,0],[0,0.1], '-c');
% %                 patch(objectSurfPoints3(:,1),objectSurfPoints3(:,2),objectSurfPoints3(:,3), 'blue');
%                  patch('Faces',[objFaces],'Vertices',[objVerts3],'FaceColor','red');
% %                 pause;

           else
               disp("COLLISION!!!!!!!");
%                disp(xCoords);
%                disp(yCoords);
%                disp(zCoords);
%                j=j+1;
%                  axis equal
% %                  hold on;
% %                  plot3([0,0], [0,0.05934705],[0,0], '-g', [0,-0.01005543], [0,0],[0,0], '-r', [0,0], [0,0],[0,0.06549042], '-c');%-0.01005543 0.05934705 0.06549042
% %                  patch(objectSurfPoints3(:,1),objectSurfPoints3(:,2),objectSurfPoints3(:,3), 'blue');%'Faces',[objFaces],'Vertices',[objVerts3],'FaceColor','red');
% %                  hold on;
%                  patch('Faces',[objFaces],'Vertices',[objVerts3],'FaceColor','red');
% %                   patch('Faces',[objFaces;handFaces],'Vertices',[objVerts3;handVerts],'FaceColor','red');
% %                 pause;  
           end

       end
 
%                axis equal
%                hold on;
%                plot3([0,0], [0,0.1],[0,0], '-g', [0,0.1], [0,0],[0,0], '-r', [0,0], [0,0],[0,0.1], '-c');
%                plot(xv,yv,'LineWidth',2)
% %                patch('Faces',[objFaces],'Vertices',[objVerts3],'FaceColor','red');
%                patch('Faces',[handFaces],'Vertices',[handVerts],'FaceColor','red');
% %                pause;
%                
    end
end


%%%%%%%%%%TO DISPLAY OBJECT POINT CLOUD 
 
       % Used for displaying the points
       
%               ptCloud = pointCloud(objectSurfPoints);
%            pcwrite(ptCloud,'object3d.pcd','Encoding','ascii');
%            pc = pcread('object3d.pcd');
%            pcshow(pc);
%            
%            ptCloudtransformed = pointCloud(objectSurfPoints)
%            pcwrite(ptCloudtransformed,'object3dtrans.pcd','Encoding','ascii');
%            pct = pcread('object3dtrans.pcd');
%            pcshowpair(pc,pct);
%            pause;