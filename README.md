# Collision_Detection_Hand_Object
This Project reads in an STL file of an object, and outputs a file of all possible valid starting positions of the object for which near contact grasping can be performed.

## Nomenclature
Each folder under the name Simulation Section describes a  type of hand orienation and a shape of the object. 
* TD is Top Down Grasp
* SIDE is the Tilted Grasp 
* 'Simulation Section'  without the above two extensions is the SIDE Grasp
* 'Basic' generates STarting Coordinates for the following shapes in three different sizes (S,M,L):
	* Cube
	* Cylinder
	* Cube 45 (Tilted by 45 degrees along z axis)
	* Two types of Vases
	* Two types of Cones
* 'Bottle' refers to a Bottle shaped object
* 'Lemon' refers to a lemon shaped object
* 'RectBowl' refers to a Rectangular shaped Bowl

## How to Run
We have separated the shapes into different folders so they cna be run simlutaneously and coordinated can be generated parallely.

* To run 'Simulation Section_SIDE Basic', go into the folder
* Open Matlab and run the file 'getValidInitCoords.m'
* The procedure is the same for any of the folders
* The coordinates are saved inside their respective folder. You can find information on the names of these coordinate files in 'getValidInitCoords.m' 
