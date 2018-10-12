/* Ripley's K and L function for N-STORM molecule dots          */
/* https://en.wikipedia.org/wiki/Spatial_descriptive_statistics */
/* by Chunyuan Zhou, 2018.10.12                                 */

/****************************************************************/
  maxRadius = 2000;
  curvPoints = 10;
  
  Dialog.create("Input parameters");
  Dialog.addNumber("Max Radius (nm):", maxRadius );
  Dialog.addNumber("Ripley curve points:", curvPoints );
  Dialog.show();

  maxRadius = Dialog.getNumber();
  curvPoints = Dialog.getNumber();;

/****************************************************************/
dataStr = File.openAsString("");
line = split(dataStr ,"\n");

numOfPoints = lengthOf(line)-1;
print(numOfPoints);
x = newArray(numOfPoints );
y = newArray(numOfPoints );

for(i=0; i<numOfPoints ;i++){
    item = split(line[i+1],"\t");
    x[i]=parseFloat(item[3]);
    y[i]=parseFloat(item[4]);
}

Array.getStatistics(x, x_min, x_max, mean, stdDev);
Array.getStatistics(y, y_min, y_max, mean, stdDev);

pixelSize = 20.0;// nm per pixel
imgW = (x_max-x_min)/pixelSize;
imgH = (y_max-y_min)/pixelSize;

newImage("Untitled", "16-bit black", imgW, imgH, 1);

for(n=0;n<numOfPoints ;n++){
      i = (x[n]-x_min)/pixelSize;
      j = (y[n]-y_min)/pixelSize;
	setPixel(i,j,65535);
}
updateDisplay();
/***************************************************/

Rip = newArray(curvPoints );
rad = newArray(curvPoints );
dr = maxRadius /curvPoints ;

for(n=0;n<curvPoints ;n++){
 rad[n] = n*dr+1;
 Rip[n] = Ripley(rad[n]);
 print(Rip[n]);
}
Plot.create("Ripley", "Distance","L(r)-r", rad, Rip);
Plot.show();
/***************************************************/
function Ripley(t){

    A = imgW*imgH*pixelSize*pixelSize;//area
    lmda = numOfPoints/A;

    I=0;
    for(i=0;i<numOfPoints ;i++){

	I0=0;

	for(j=0;j<numOfPoints ;j++){
		if(i!=j){
			dij2=(x[i]-x[j])*(x[i]-x[j])+(y[i]-y[j])*(y[i]-y[j]);
			if(dij2 < t*t){
				I++;I0++;
	            }
		}
	}
	Overlay.clear();	
	Overlay.drawEllipse(x[i]-t, y[i]-t, t*2, t*2);
	Overlay.drawString("��ƽ���ܶȡ�:"+lmda+" ������뾶��:"+t,0,24,0);
	Overlay.drawString("�����μ�����:"+I0+"�����ۼ�����:"+(lmda*PI*t*t),0,24*2,0);
      Overlay.drawString("������:"+(imgW*pixelSize)+","+(imgH*pixelSize)+"���ܼ�����:"+I,0,24*3,0);
	Overlay.show();
      showProgress(i, numOfPoints );
    }
    K = (I/lmda)/numOfPoints ; /*** equals to I*A/(n*n) ***/
    L = sqrt(K/PI)-t;

    Overlay.drawString("��k������:"+K+" ��L������:"+L,0,imgH/2,0);
    Overlay.show();
    return L;
}
