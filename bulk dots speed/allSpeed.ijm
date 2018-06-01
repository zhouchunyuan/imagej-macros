w = getWidth();
h = getHeight();

hw = 5;
hh = 5;


for(frame=1;frame<nSlices;frame++){

totalDistance = 0;
count=0;

showProgress(frame, nSlices);
setSlice(frame);
var p = newArray(w*h);
for(j=1;j<h-1;j++){
	for(i=1;i<w-1;i++){
		p[j*w+i]=getPixel(i,j);
	}
}

setSlice(frame+1);
for(j=1+hh;j<h-1-hh;j++){
	for(i=1+hw;i<w-1-hw;i++){
		dmin = 200;
		if(p[j*w+i]!=0){
			for(y=-hh;y<=hh;y++){
				for(x=-hw;x<=hw;x++){
					v = getPixel(x+i,y+j);
					if(v!=0){
						d=sqrt(x*x+y*y);
						if(dmin>d)dmin=d;
					}
					
				}
			}
			
		}
		if(dmin!=200 && dmin!=0){
			count++;
			totalDistance +=dmin;
		}
	}
}
//setResult("count", frame-1, ""+count);
//setResult("all distance", frame-1, ""+totalDistance);
setResult("speed", frame-1, ""+(totalDistance/count));

}
showMessage("finish");
