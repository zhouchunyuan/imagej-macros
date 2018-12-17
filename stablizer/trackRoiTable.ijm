/*****************************************
This is almost same code as "trackRoi.ijm"
except at the end, it creates a table.
*****************************************/
enableMirror = false;

edge = 4;//pixels
mainTitle = getTitle();

Roi.getBounds(x, y, width, height);
roiArea = newArray(width*height);
mirrorArea = newArray(width*height);

/********* take 1st frame as ref ***********/
setSlice(1);
   for(j=0;j<height;j++)
      for(i=0;i<width;i++){
         roiArea[j*width+i]=getPixel(i+x,j+y);
   }

/********* display mirror *****************/
if(enableMirror)newImage("mirror", "8-bit black", width, height, 1);

selectWindow(mainTitle);
XtoMove = newArray(nSlices);
YtoMove = newArray(nSlices);
for(n=2;n<=nSlices;n++){
   setSlice(n);

   bestX = x;bestY = y; bestSum =0;

   for(Y=-edge;Y<=edge;Y++)
      for(X=-edge;X<=edge;X++){

         sumAB = 0;sumAsqr=0;sumBsqr=0;
         for(j=0;j<height;j++)
            for(i=0;i<width;i++){
               a =getPixel(i+X+x,j+Y+y);
               b =roiArea[j*width+i];
               sumAB+=a*b;
               sumAsqr+=a*a;
               sumBsqr+=b*b;
         }
         sumAB = sumAB/(sqrt(sumAsqr)*sqrt(sumBsqr));

         if(sumAB>bestSum){
            bestSum = sumAB;
            bestX = X;
            bestY = Y;
         }
   }

   XtoMove[n-1] =XtoMove[n-2]+bestX;
   YtoMove[n-1] =YtoMove[n-2]+bestY;
   
   Roi.move(bestX+x, bestY+y);
   x = bestX+x;y=bestY+y;

   /******************************/
   if(enableMirror){
      for(j=0;j<height;j++)
         for(i=0;i<width;i++){
            mirrorArea[j*width+i]=getPixel(i+x,j+y);
      }
      selectWindow("mirror");
      for(j=0;j<height;j++)
         for(i=0;i<width;i++){
            setPixel(i,j,mirrorArea[j*width+i]);
      }
      updateDisplay();
	selectWindow(mainTitle);
   }
   
}

/****** table function copy from https://imagej.nih.gov/ij/macros/SineCosineTable2.txt */
title1 = "Tracking Table";
title2 = "["+title1+"]";
f = title2;
if (isOpen(title1))
  print(f, "\\Clear");
else
  run("Table...", "name="+title2+" width=250 height=600");
print(f, "\\Headings:n\tX\tY");
for(i=0;i<XtoMove.length;i++){
  print(f, i+"\t"+XtoMove[i] + "\t" + YtoMove[i]);
}


