/* in a 3x3 matrix, the 4th element is the center */
/* if v[4] is larger than other elements, the current x,y is considered as a peak */

w = getWidth();
h = getHeight();

for(frame=1;frame<=nSlices;frame++){
showProgress(frame, nSlices);
setSlice(frame);
var p = newArray(w*h);
for(j=1;j<h-1;j++){
	for(i=1;i<w-1;i++){

		v = newArray(9);
		for(m=-1;m<=1;m++){
			for(n=-1;n<=1;n++){
				idx = (m+1)*3+(n+1);
			    v[(m+1)*3+(n+1)] = getPixel(i+n,j+m);
			}
		}
		isCenter = true;
		for(c=0;c<9;c++){
			if(v[4]<v[c]){
				//print(v[4]+":"+v[c]);
				isCenter = false;
				break;
			}
		}
		if(isCenter && v[4]>100)p[j*w+i]=v[4];
 
	}
}
//newImage("Untitled", "16-bit black", w, h, 1);
for(j=1;j<h-1;j++){
	for(i=1;i<w-1;i++){

	setPixel(i, j, p[j*w+i]);
 
	}
}
}
showMessage("finish");
