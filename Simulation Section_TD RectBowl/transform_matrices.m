function renderFromStructTree()
    global euler_list;
    global quat_list;
    global pos_list;
    global names_list;
    global num_i;
    names_list = [];
    global matrices_int;
    matrices_list = [];
    matrices_int = 1;
    num_i = 1;
%     global Faces;
    Faces = [];
%     global Verts;
    Verts = [];
    filename = "hello_VERTS.txt"
    filename2 = "hello_FACES.txt"
    if exist(filename, 'file') == 2
     delete(filename);
    end
    if exist(filename2, 'file') == 2
     delete(filename2);
    end    
    % Given Mujoco XML file, return struct of major components
    filename = "j2s7s300_end_effector_v1_sbox.xml";
    [handStruct,objStruct,meshStruct] = XMLtoStructSTL(filename);
    allStructs = {handStruct};
    numStructs = size(allStructs);
    numStructs = numStructs(2);
    disp("NUMSTRUCTS");
    disp(numStructs);
    
    %figure;
    for n = 1:numStructs
        currStruct = allStructs{n};
        %disp("MAIN currStruct.Attributes.name: ");
        %disp(currStruct.Attributes.name);
        
        [Verts, Faces] = partTransform(currStruct, meshStruct, Verts, Faces);
        
        % If current struct has inner body, transform inner sections
        if isfield(currStruct,'body') == 1
            isLeaf = 0;
            %disp("HAS BODY: currStruct.Attributes.name: ");
            %disp(currStruct.Attributes.name);
            [Verts, Faces] = innerTransform(currStruct, meshStruct, isLeaf, Verts, Faces);
        else
            isLeaf = 1;
        end
    end
    
    save_mesh();
    
%     disp("SIZES FACES\n");
%     disp(size(Faces));
%     disp("SIZES VERTICES\n");
%     disp(size(Verts)); 
    %fv = cat(1, partFaces, partVerts);
%     stlwrite("./new_hand_full.stl",Faces, Verts,'mode','ascii');%/Users/asar/Desktop/Grimm's\ Lab/Grasping/Codes/CollisionDetection/Simulation\ Section
    %disp("matrices_int: "+ matrices_int);
%     [handVerts, handFaces, handNormals, handName] = stlRead("new_hand_full.stl");%"finger_distal.STL"
%     disp("SIZES FACESREAD\n");
%     disp(size(handFaces));
%     disp("SIZES VERTICESREAD\n");
%     disp(size(handVerts));
%     
%     axis equal
%     patch('Faces',Faces,'Vertices',Verts,'FaceColor','red');

end

% Return correct mesh filename from mesh struct
function [meshFile] = getMesh(currPart,meshStruct,numMeshes,shapesFile,handFile)
    % Object - if type = mesh, euler, if type = geom, pos, euler
    if strcmp(currPart.Attributes.type,"mesh") == 1
        objMeshName = currPart.Attributes.mesh;
        for i = 1:numMeshes
            meshName = meshStruct{i}.Attributes.name;
            meshDir = handFile;
            if strcmp(objMeshName,meshName) == 1
                if strcmp(currPart.Attributes.name,"object") == 1
                    meshDir = shapesFile;
                else
                    meshDir = handFile;
                end
                meshFile = meshDir + meshStruct{i}.Attributes.file;
            end
        end
    end
    if strcmp(currPart.Attributes.type,"cylinder") == 1
       cylinder_file = "cylinder.stl";
        % Get correctly-sized cylinder
        if isfield(currPart.Attributes,'size') == 1
            cyl_size = currPart.Attributes.size;
            cyl_size = strsplit(cyl_size);
            cyl_size = str2double(cyl_size);
            cyl_size = cyl_size(1);

            if cyl_size == 0.002
                cylinder_file = "cylinder_002.stl";
            elseif cyl_size == 0.005
                cylinder_file = "cylinder_005.stl";
            end
        end
       meshFile = handFile + cylinder_file;
    end
end

function [Verts, Faces] = innerTransform(currStruct, meshStruct, isLeaf, Verts, Faces)
    b = 0;
    numBodies = size(currStruct.body);
    numBodies = numBodies(2);
    
    while b < numBodies 
        b = b + 1;
        if numBodies > 1
            bodyStruct = currStruct.body{b};
        else
            bodyStruct = currStruct.body;
        end

        %disp("INNER bodyStruct.Attributes.name: ");
        %disp(bodyStruct.Attributes.name);
        [Verts, Faces] = partTransform(bodyStruct, meshStruct, Verts, Faces);
        
        % Traverse and transform inner parts until leaf node
        if isfield(bodyStruct,'body') == 1
            isLeaf = 0;
            [Verts, Faces] = innerTransform(bodyStruct, meshStruct, isLeaf, Verts, Faces);
        else
           isLeaf = 1; 
        end
    end
end

function [Verts, Faces] = partTransform(currStruct, meshStruct, Verts, Faces)
    numMeshes = size(meshStruct);
    numMeshes = numMeshes(2);
    meshFile = '';
    shapesFile = "shape_meshes/";
    handFile = "hand_meshes/";
    geomNum = 1;
    siteNum = 1;
    currPart = 0;
    global num_i;

    
    % Append the outter body transformation
    append_to_list(currStruct);
    
    % Hold number of geoms and sites within current body
    currStructGeoms = 0;
    currStructSites = 0;

    if isfield(currStruct,'geom') == 1
        num = size(currStruct.geom);
        currStructGeoms = num(2);
    end

    if isfield(currStruct,'site') == 1
        num = size(currStruct.site);
        currStructSites = num(2);
    end
    
    % Total meshes/objects within component part body
    numParts = currStructGeoms + currStructSites;
    partVerts = [];
    partFaces = [];
    
    for k = 1:numParts
        %disp("numParts: "+numParts);
        if geomNum <= currStructGeoms
            if currStructGeoms > 0
              %disp("GEOM");
              if currStructGeoms > 1
                currPart = currStruct.geom{geomNum}; 
              else
                currPart = currStruct.geom;
              end
              geomNum = geomNum + 1;
            end
        else
            if currStructSites > 0
              %disp("SITE");
              if currStructSites > 1
                currPart = currStruct.site{siteNum}; 
              else
                currPart = currStruct.site;
              end
              siteNum = siteNum + 1;
            end
        end
        
        %disp("PART currpart.Attributes.name: ");
        %disp(currPart.Attributes.name + "," + num_i);
        append_to_list(currPart);

        % Return correct mesh filename
        meshFile = getMesh(currPart,meshStruct,numMeshes,shapesFile,handFile);

        % Read mesh from stl file
        [objVerts, objFaces, objNormals, objName] = stlRead(meshFile);
        %disp("number is:");
        %disp(num_i);
        objVerts = try_transform(currStruct, objVerts, objFaces, num_i);
        num_i = num_i + 1;
        partVerts = cat(1, partVerts, objVerts);
        partFaces = cat(1, partFaces, objFaces);
        %disp("size of finalVerts: "+size(partVerts));
        fid = fopen('hello_VERTS.txt','at');
        fprintf(fid, '%f %f %f\n', partVerts);
        fclose(fid);
    
        fid = fopen('hello_FACES.txt','at');
        fprintf(fid, '%f %f %f\n', partFaces);
        fclose(fid);
        
    end
    
   
end

function append_to_list(currStruct)
    global euler_list;
    global quat_list;
    global pos_list;
    global matrices_int;    
    global names_list;
    
    bodyEulM = [1 1 1];
    bodyQuatM = [1 1 1 1];
    bodyPosM = [0 0 0];

    %disp("append to list, currStruct.Attributes.name: "+currStruct.Attributes.name);
        
    if isfield(currStruct.Attributes,'quat')
        bodyQuatM = currStruct.Attributes.quat;
        bodyQuatM = strsplit(bodyQuatM);
        bodyQuatM = str2double(bodyQuatM);
        %disp("HELLO quat");
        %disp(bodyQuatM);
    end
    
        % Euler rotation
    if isfield(currStruct.Attributes,'euler')
        bodyEulM = currStruct.Attributes.euler;
        bodyEulM = strsplit(bodyEulM);
        bodyEulM = str2double(bodyEulM);
        %disp("HELLO Eul");
        %disp(bodyEulM);
    end
    
    if isfield(currStruct.Attributes,'pos')
        %bodyPosM = currStruct.Attributes.pos;
        %bodyPosM = strsplit(bodyPosM);
        %bodyPosM = str2double(bodyPosM);
        %disp("HELLO Pos");
        %disp(bodyPosM);
    end
    euler_list(matrices_int,:) = bodyEulM;
    quat_list(matrices_int,:) = bodyQuatM;
    pos_list(matrices_int,:) = bodyPosM;
    matrices_int = matrices_int + 1;
    
    %disp(currStruct.Attributes.name);
    %disp("EUL List is:");
    %disp(euler_list);
    
    %disp("QUAT List is:");
    %disp(quat_list);
    
    %disp("POS List is:");
    %disp(pos_list);
    
    %disp("BEFORE names_list: ");
    %disp(names_list);
    name = string(currStruct.Attributes.name);
    names_list = [names_list, name];
    %disp("AFTER names_list: ");
    %disp(names_list);
    
    %disp("NAMES List is:");
    name_num = size(names_list);
    name_num = name_num(2);
    %for i = 1:name_num
        %disp(names_list(i));
    %end
end

function get_list()
    global euler_list;
    global quat_list;
    global pos_list;
    global matrices_int;
    
    % Get the palm transforms
    palm_list = [];
    for k = 1:numParts
       palm_euler = [euler_list, pos_list(k)];
       
    end
    
end

function [objVerts] = try_transform(currStruct, objVerts, objFaces, num_i)
    global Faces;
    global Verts;

    cam_rot = [0 90 0 0]; %quat
    cam_pos = [0 -0.1 0.1];
    
    scale_palm = [0.005];
    scale_fingers = [0.002];
  
    link_7_rot = [-1.57 0 -1.57];
    link_7_pos = [0.0 0.18 0.0654];
    
    palm_cyl_rot = [0 1 0 0]; %quat
    palm_cyl_pos = [0.0 0.0 -0.11];
    
    palm1_cyl_rot = [0 1 0 0]; %quat
    palm1_cyl_pos = [0.02 0.0 -0.11];
    
    palm2_cyl_rot = [0 1 0 0]; %quat
    palm2_cyl_pos = [-0.02 0.0 -0.11];    
    
    palm3_cyl_rot = [0 1 0 0]; %quat
    palm3_cyl_pos = [0.0 -0.015 -0.11];
    
    palm4_cyl_rot = [0 1 0 0]; %quat
    palm4_cyl_pos = [0.0 0.015 -0.11];
    
    
    finger_1_rot = [0.379408 -0.662973 -0.245899 0.596699]; %quat
    finger_1_pos = [0.00279 0.03126 -0.11467];
    
    f1_prox_1_rot = [1.57 3.14 1.57];
    f1_prox_1_pos = [0.02 0 0];
    
    f1_prox_cyl_rot = [1.57 3.14 1.57];
    f1_prox_cyl_pos = [0.03 0 0];
    
    finger_tip_1 = [0.044 -0.003 0];
    
    f1_dist_1_rot = [1.57 3.14 1.57];
    f1_dist_1_pos = [0.02 0 0];
    
    f1_dist_cyl_rot = [1.57 3.14 1.5];
    f1_dist_cyl_pos = [0.03 0 0];
    
    finger_2_rot = [0.659653 -0.37146 0.601679 -0.254671]; %quat
    finger_2_pos = [0.02226 -0.02707 -0.11482];
    
    f2_prox_1_rot = [1.57 3.14 1.57];
    f2_prox_1_pos = [0.02 0 0];
    
    f2_prox_cyl_rot = [1.57 3.14 1.57];
    f2_prox_cyl_pos = [0.03 0 0];
    
    finger_tip_2 = [0.044 -0.003 0];
    
    f2_dist_1_rot = [1.57 3.14 1.57];
    f2_dist_1_pos = [0.02 0 0];
    
    f2_dist_cyl_rot = [1.57 3.14 1.5];
    f2_dist_cyl_pos = [0.03 0 0];
    
    finger_3_rot = [0.601679 -0.254671 0.659653 -0.37146]; %quat
    finger_3_pos = [-0.02226 -0.02707 -0.11482];
    
    f3_prox_1_rot = [1.57 3.14 1.57];
    f3_prox_1_pos = [0.02 0 0];
    
    f3_prox_cyl_rot = [1.57 3.14 1.57];
    f3_prox_cyl_pos = [0.03 0 0];
    
    finger_tip_3 = [0.044 -0.003 0];
    
    f3_dist_1_rot = [1.57 3.14 1.57];
    f3_dist_1_pos = [0.02 0 0];
    
    f3_dist_cyl_rot = [1.57 3.14 1.57];
    f3_dist_cyl_pos = [0.03 0 0];
       

    cam_rot = quat2rotm(cam_rot);
    cam_rot(end+1,4) = 1;
    
    link_7_rot = eul2rotm(link_7_rot, 'XYZ');
    link_7_rot(end+1,4) = 1;
    
    palm_cyl_rot = quat2rotm(palm_cyl_rot);
    palm_cyl_rot(end+1,4) = 1;
    
    palm1_cyl_rot = quat2rotm(palm1_cyl_rot);
    palm1_cyl_rot(end+1,4) = 1;
    
    palm2_cyl_rot = quat2rotm(palm2_cyl_rot);
    palm2_cyl_rot(end+1,4) = 1;
    
    palm3_cyl_rot = quat2rotm(palm3_cyl_rot);
    palm3_cyl_rot(end+1,4) = 1;
    
    palm4_cyl_rot = quat2rotm(palm4_cyl_rot);
    palm4_cyl_rot(end+1,4) = 1;
    
    finger_1_rot = quat2rotm(finger_1_rot);
    finger_1_rot(end+1,4) = 1;
    
    finger_2_rot = quat2rotm(finger_2_rot);
    finger_2_rot(end+1,4) = 1;
    
    finger_3_rot = quat2rotm(finger_3_rot);
    finger_3_rot(end+1,4) = 1;
    
    f1_dist_1_rot = eul2rotm(f1_dist_1_rot, 'XYZ');
    f1_dist_1_rot(end+1,4) = 1;

    f1_dist_cyl_rot = eul2rotm(f1_dist_cyl_rot, 'XYZ');
    f1_dist_cyl_rot(end+1,4) = 1;

    f1_prox_1_rot = eul2rotm(f1_prox_1_rot, 'XYZ');
    f1_prox_1_rot(end+1,4) = 1;
    
    f1_prox_cyl_rot = eul2rotm(f1_prox_cyl_rot, 'XYZ');
    f1_prox_cyl_rot(end+1,4) = 1;
    
    f2_dist_1_rot = eul2rotm(f2_dist_1_rot, 'XYZ');
    f2_dist_1_rot(end+1,4) = 1;

    f2_dist_cyl_rot = eul2rotm(f2_dist_cyl_rot, 'XYZ');
    f2_dist_cyl_rot(end+1,4) = 1;

    f2_prox_1_rot = eul2rotm(f2_prox_1_rot, 'XYZ');
    f2_prox_1_rot(end+1,4) = 1;
    
    f2_prox_cyl_rot = eul2rotm(f2_prox_cyl_rot, 'XYZ');
    f2_prox_cyl_rot(end+1,4) = 1;
    
    f3_dist_1_rot = eul2rotm(f3_dist_1_rot, 'XYZ');
    f3_dist_1_rot(end+1,4) = 1;

    f3_dist_cyl_rot = eul2rotm(f3_dist_cyl_rot, 'XYZ');
    f3_dist_cyl_rot(end+1,4) = 1;

    f3_prox_1_rot = eul2rotm(f3_prox_1_rot, 'XYZ');
    f3_prox_1_rot(end+1,4) = 1;
    
    f3_prox_cyl_rot = eul2rotm(f3_prox_cyl_rot, 'XYZ');
    f3_prox_cyl_rot(end+1,4) = 1;    

    scale_palm = makehgtform('scale',scale_palm);
    scale_fingers = makehgtform('scale',scale_fingers);
    
    cam_pos = makehgtform('translate',cam_pos);
    link_7_pos = makehgtform('translate',link_7_pos);
    
    palm_cyl_pos = makehgtform('translate',palm_cyl_pos);
    palm1_cyl_pos = makehgtform('translate',palm1_cyl_pos);
    palm2_cyl_pos = makehgtform('translate',palm2_cyl_pos);
    palm3_cyl_pos = makehgtform('translate',palm3_cyl_pos);
    palm4_cyl_pos = makehgtform('translate',palm4_cyl_pos);
    
    finger_1_pos = makehgtform('translate',finger_1_pos);
    finger_2_pos = makehgtform('translate',finger_2_pos);
    finger_3_pos = makehgtform('translate',finger_3_pos);

    f1_prox_1_pos = makehgtform('translate',f1_prox_1_pos);
    f1_prox_cyl_pos = makehgtform('translate',f1_prox_cyl_pos);
    finger_tip_1 = makehgtform('translate',finger_tip_1);
    f1_dist_1_pos = makehgtform('translate',f1_dist_1_pos);
    f1_dist_cyl_pos = makehgtform('translate',f1_dist_cyl_pos);

    f2_prox_1_pos = makehgtform('translate',f2_prox_1_pos);
    f2_prox_cyl_pos = makehgtform('translate',f2_prox_cyl_pos);
    finger_tip_2 = makehgtform('translate',finger_tip_2);
    f2_dist_1_pos = makehgtform('translate',f2_dist_1_pos);
    f2_dist_cyl_pos = makehgtform('translate',f2_dist_cyl_pos);
    
    f3_prox_1_pos = makehgtform('translate',f3_prox_1_pos);
    f3_prox_cyl_pos = makehgtform('translate',f3_prox_cyl_pos);
    finger_tip_3 = makehgtform('translate',finger_tip_3);
    f3_dist_1_pos = makehgtform('translate',f3_dist_1_pos);
    f3_dist_cyl_pos = makehgtform('translate',f3_dist_cyl_pos);
    
    if(num_i==1)
        M = link_7_pos*link_7_rot;
        
    elseif (num_i==2)
        M = link_7_pos*link_7_rot*palm_cyl_pos*palm_cyl_rot*scale_palm;
         
     elseif (num_i==3)
        M = link_7_pos*link_7_rot*palm1_cyl_pos*palm1_cyl_rot*scale_palm;
       
    elseif (num_i==4)
        M = link_7_pos*link_7_rot*palm2_cyl_pos*palm2_cyl_rot*scale_palm;
         
    elseif (num_i==5)
        M = link_7_pos*link_7_rot*palm3_cyl_pos*palm3_cyl_rot*scale_palm;
         
    elseif (num_i==6)
        M = link_7_pos*link_7_rot*palm4_cyl_pos*palm4_cyl_rot*scale_palm;
    
    elseif (num_i==7)
        M = link_7_pos*link_7_rot*finger_1_pos*finger_1_rot;
         
    elseif (num_i==8)
        M = link_7_pos*link_7_rot*finger_1_pos*finger_1_rot*f1_prox_cyl_pos*f1_prox_cyl_rot*scale_fingers;%
          
     elseif (num_i==9)
        M = link_7_pos*link_7_rot*finger_1_pos*finger_1_rot*f1_prox_1_pos*f1_prox_1_rot*scale_fingers;%
 
     elseif (num_i==10)        
        M = link_7_pos*link_7_rot*finger_1_pos*finger_1_rot*finger_tip_1;%
     
     elseif (num_i==11)        
        M = link_7_pos*link_7_rot*finger_1_pos*finger_1_rot*finger_tip_1*f1_dist_cyl_pos*f1_dist_cyl_rot*scale_fingers;%
      
     elseif (num_i==12)
        M = link_7_pos*link_7_rot*finger_1_pos*finger_1_rot*finger_tip_1*f1_dist_1_pos*f1_dist_1_rot*scale_fingers;%
         
     elseif (num_i==13)
         M = link_7_pos*link_7_rot*finger_2_pos*finger_2_rot;
        
     elseif (num_i==14)
         M = link_7_pos*link_7_rot*finger_2_pos*finger_2_rot*f2_prox_cyl_pos*f2_prox_cyl_rot*scale_fingers;
         
     elseif (num_i==15)
         M = link_7_pos*link_7_rot*finger_2_pos*finger_2_rot*f2_prox_1_pos*f2_prox_1_rot*scale_fingers;
 
    elseif (num_i==16)        
        M = link_7_pos*link_7_rot*finger_2_pos*finger_2_rot*finger_tip_2;
     
    elseif (num_i==17)        
         M = link_7_pos*link_7_rot*finger_2_pos*finger_2_rot*finger_tip_2*f2_dist_cyl_pos*f2_dist_cyl_rot*scale_fingers;
     
    elseif (num_i==18)
         M = link_7_pos*link_7_rot*finger_2_pos*finger_2_rot*finger_tip_2*f2_dist_1_pos*f2_dist_1_rot*scale_fingers;
         
    elseif (num_i==19)
        M = link_7_pos*link_7_rot*finger_3_pos*finger_3_rot;
     
    elseif (num_i==20)
        M = link_7_pos*link_7_rot*finger_3_pos*finger_3_rot*f3_prox_cyl_pos*f3_prox_cyl_rot*scale_fingers;
     
    elseif (num_i==21)
        M = link_7_pos*link_7_rot*finger_3_pos*finger_3_rot*f3_prox_1_pos*f3_prox_1_rot*scale_fingers;
     
    elseif (num_i==22)        
        M = link_7_pos*link_7_rot*finger_3_pos*finger_3_rot*finger_tip_3;
     
    elseif (num_i==23)        
        M = link_7_pos*link_7_rot*finger_3_pos*finger_3_rot*finger_tip_3*f3_dist_cyl_pos*f3_dist_cyl_rot*scale_fingers;
        
    elseif (num_i==24)
        M = link_7_pos*link_7_rot*finger_3_pos*finger_3_rot*finger_tip_3*f3_dist_1_pos*f3_dist_1_rot*scale_fingers;
        
    else
        M = eye(4);
    end

    verts = objVerts;
    verts(:,4)  = 1;
    verts = verts';
    verts = M*verts;
    verts = verts';
    objVerts = verts(:, 1:3);
    
    %disp("ADDING");
    %disp(currStruct.Attributes.name);
    
%     Verts = [Verts; verts(:, 1:3)];
%     Faces = [Faces; objFaces];
end

function save_mesh()
    filename = "hello_VERTS.txt";
    fileID = fopen(filename);
    verts_in = textscan(fileID,'%f %f %f');
    Verts = [verts_in{1}, verts_in{2}, verts_in{3}];
    fclose(fileID);
    
    filename = "hello_FACES.txt";
    fileID = fopen(filename);
    faces_in = textscan(fileID,'%f %f %f');
    Faces = [faces_in{1}, faces_in{2}, faces_in{3}];
    fclose(fileID);
    
    disp(size(Verts));
    disp(size(Faces));
    
    axis equal
    hold on;
     plot3([0,0], [0,0.1],[0,0], '-g', [0,0.1], [0,0],[0,0], '-r', [0,0], [0,0],[0,0.1], '-c');
    patch('Faces',Faces,'Vertices',Verts,'FaceColor','red');    
    
end
