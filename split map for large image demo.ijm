/**********************************************
*This is to split an RGB image into m x n pieces
*to meet the requirement of NIS-Elements stitching patten
*JOBS need "bottom-up" with "X mirror"
**********************************************/
overlap = 0.1;
m = 6.0;
n = 5.0;
x_mirror = false;

Dialog.create("split map");
Dialog.addNumber("overlap:", overlap);
Dialog.addChoice("direction:", newArray("top-down", "bottom-up"));
Dialog.addNumber("X split number:", m);
Dialog.addNumber("Y split number:", n);
Dialog.addCheckbox("X mirror", x_mirror);
Dialog.show();
overlap = Dialog.getNumber();
dir = Dialog.getChoice();
m = Dialog.getNumber();
n = Dialog.getNumber();
x_mirror = Dialog.getCheckbox();

getDimensions(width, height, channels, slices, frames);
mapfile = getTitle();

//equavelent number of blocks in X and Y
mm = m-overlap*m+overlap;
nn = n-overlap*n+overlap;
//actuall width height
ww = width/mm;
hh = height/nn;
newImage("mapStack", "RGB black", ww, hh, 1);
inv = 0;
alfa = 1-overlap;
xi=0.0;xj=0.0;//the real coordinates

for(j=0;j<n;j++){
	for(i=0;i<m;i++){
		selectWindow(mapfile);
		if(dir=="top-down"){xi=i;xj=j;}
		if(dir=="bottom-up"){xi=i;xj=n-j-1;}
		if(x_mirror){xi=m-i-1;}
		if(!inv){
			left = xi*ww*alfa;
			top = xj*hh*alfa;
		}else{
			left = width-(xi+1)*ww*alfa-ww*overlap;
			top =xj*hh*alfa;
		}
		makeRectangle(left,top,ww,hh);
		//setForegroundColor(255, 105, 0);
		//run("Draw", "slice");//show the blocks
		
		run("Copy");
		selectWindow("mapStack");
		run("Paste");
		run("Add Slice");
		
	//wait(100);
	}
	inv=!inv;
}
run("Delete Slice");//last slice is blank
