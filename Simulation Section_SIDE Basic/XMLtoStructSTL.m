%function [meshStruct,palmStruct,finger1Struct,finger2Struct,finger3Struct,objStruct] = XMLtoStructSTL()
function [handStruct,objStruct,meshStruct] = XMLtoStructSTL(filename)
    stlStruct = xml2struct(filename);
    
    % Mujoco assets (meshes)
    meshStruct = stlStruct.mujoco.asset.mesh;
    
    % Hand with palm, fingers and inner body components
    handStruct = stlStruct.mujoco.worldbody.body{1}.body;
    
    % Object body
    objStruct = stlStruct.mujoco.worldbody.body{2};
    
    % Fingers j2s7s300_link_finger_1, j2s7s300_link_finger_2,
    % j2s7s300_link_finger_3
    %finger1Struct = stlStruct.mujoco.worldbody.body{1}.body.body{1};
    %finger2Struct = stlStruct.mujoco.worldbody.body{1}.body.body{2};
    %finger3Struct = stlStruct.mujoco.worldbody.body{1}.body.body{3};
end