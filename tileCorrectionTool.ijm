  /**********************************************/
  var IMG_W;
  var IMG_H;
  var TIL_W;
  var TIL_H;
  var NUM_X = 17;
  var NUM_Y = 9;
  var OVRLP = 0.1; // overlap
  
  var fixCurvX;
  var fixCurvY;

  /**********************************************/
  
  macro "Set Parameters Action Tool - C059T0e10ST7e10eTee10t" {
        IMG_W = getWidth();
        IMG_H = getHeight();
        Dialog.create("Parameters");
        Dialog.addMessage("Width:"+IMG_W+" Height:"+IMG_H);
        Dialog.addNumber("Tiling Number X:", NUM_X);
        Dialog.addNumber("Tiling Number Y:", NUM_Y);
        Dialog.addNumber("Overlap:", OVRLP);
        Dialog.show();
        NUM_X = Dialog.getNumber();
        NUM_Y = Dialog.getNumber();
        OVRLP = Dialog.getNumber();
  
        TIL_W =parseInt( IMG_W/((1-OVRLP)*(NUM_X-1)+1) );
        TIL_H =parseInt( IMG_H/((1-OVRLP)*(NUM_Y-1)+1) );

        setResult("Image X", 0, IMG_W);
        setResult("Image Y", 0, IMG_H);
        setResult("X Tile Num", 0, NUM_X);
        setResult("Y Tile Num", 0, NUM_Y);
        setResult("Tile Size X", 0, TIL_W);
        setResult("Tile Size Y", 0, TIL_H);
        setResult("Overlap", 0, OVRLP);
        setOption("ShowRowNumbers", false);
  }
  
  macro "See projection Action Tool - C059T0e10PT6e10rT9e10oTfe10j" {
        
        // get projection profiles
        projx = newArray(IMG_W);
        projy = newArray(IMG_H);
        for(j=0;j<IMG_H;j++){
                for(i=0;i<IMG_W;i++){
                        v = getPixel(i,j);
                        projx[i]+=v;
                        projy[j]+=v;
                }
        }
        

        overlapx = OVRLP*TIL_W;
        overlapy = OVRLP*TIL_H;
        effectiveSizex = parseInt( TIL_W*(1-OVRLP) );
        effectiveSizey = parseInt( TIL_H*(1-OVRLP) );
       
        fixCurvX = newArray(IMG_W);
        fixCurvY = newArray(IMG_H);

        // get fixCurvX
        for(i=0;i<IMG_W;i++){
                n = parseInt(i/effectiveSizex);
                if(n>0 && n <NUM_X){
                        x1 = parseInt(n*effectiveSizex -effectiveSizex/2);
                        x2 = parseInt(n*effectiveSizex +effectiveSizex/2);
                        idx = i-x1;
                        delta = projx[x2] - projx[x1];
                        k = delta*idx/(x2-x1);
                        absCurvValue = projx[x1]+k;
                        fixCurvX[i]= absCurvValue/projx[i];
                }else{
                        fixCurvX[i] = 1;
                }
                
                //fixCurv[i] *=proj[i];
                
        }
        
        fixCurv = newArray(IMG_W);
        for(i=0;i<IMG_W;i++)fixCurv[i] = fixCurvX[i]*projx[i];
        
        Plot.create("ProjectX","X","Sum Intensity");
        Plot.setColor("green");
        Plot.add("line",projx);
        Plot.setColor("blue");
        Plot.add("line",fixCurv);
        Plot.show();

        // get fixCurvY
        for(i=0;i<IMG_H;i++){
                n = parseInt(i/effectiveSizey);
                if(n>0 && n <NUM_Y){
                        y1 = parseInt(n*effectiveSizey -effectiveSizey/2);
                        y2 = parseInt(n*effectiveSizey +effectiveSizey/2);
                        idx = i-y1;
                        delta = projy[y2] - projy[y1];
                        k = delta*idx/(y2-y1);
                        absCurvValue = projy[y1]+k;
                        fixCurvY[i]= absCurvValue/projy[i];
                }else{
                        fixCurvY[i] = 1;
                }
        }
        
        fixCurv = newArray(IMG_H);
        for(i=0;i<IMG_H;i++)fixCurv[i] = fixCurvY[i]*projy[i];
        
        Plot.create("ProjectY","Y","Sum Intensity");
        Plot.setColor("green");
        Plot.add("line",projy);
        Plot.setColor("blue");
        Plot.add("line",fixCurv);
        Plot.show();        
        
  }

    macro "fix Action Tool - C059T0e10FT6e10iTbe10x" {
        for(j=0;j<IMG_H;j++){
                for(i=0;i<IMG_W;i++){
                        v=getPixel(i,j);
                        setPixel(i,j,fixCurvX[i]*fixCurvY[j]*v);
                }
        }
  }
  /**********************************************/
  var startx;
  var bW;
  var box;
  /**********************************************/
  macro "Increase Intensity Tool - C059T1f16+" {
      leftButton=16;
      rightButton=4;
      shift=1;
      ctrl=2; 
      alt=8;
      x2=-1; y2=-1; z2=-1; flags2=-1;
      W = getWidth();
      H = getHeight();

      getCursorLoc(x, y, z, flags);
      x0=x;y0=y;

      while (flags&leftButton!=0) {
          getCursorLoc(x, y, z, flags);

          if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
              s = " ";
              if (flags&leftButton!=0 && flags&ctrl==0){
                  Overlay.clear();
                  setColor("yellow");
                  Overlay.drawLine(x0,y0,x,y0);
                  Overlay.show();
                  xl=x0;xr=x;
                  if(xl>xr){xl=x;xr=x0;}
                  bW = xr-xl+1;
                  box = newArray(H*bW);
                  for(j=0;j<H;j++){
                      for(i=0;i<bW;i++){
                          box[j*bW+i]=getPixel(xl+i,j);
                      }
                  }
                  startx = xl;
              }
              if (flags&rightButton!=0) s = s + "<right>";
              if (flags&shift!=0) s = s + "<shift>";
              if (flags&ctrl!=0){
                  for(j=0;j<H;j++){
                      for(i=0;i<bW;i++){
                          v = box[j*bW+i];
                          k = 1+0.1*exp(-(i-bW/2)*(i-bW/2)/(2*bW/3*bW/3));
                          setPixel(startx+i,j,v*k);
                      }
                  }
              if (flags&alt!=0) s = s + "<alt>";
              //print(x+" "+y+" "+z+" "+flags + "" + s);
              //logOpened = true;
              /***********************/


              /***********************/
              
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(10);

      }
 }
 
   macro "decrease Intensity Tool - C059T3d16-" {
      leftButton=16;
      rightButton=4;
      shift=1;
      ctrl=2; 
      alt=8;
      x2=-1; y2=-1; z2=-1; flags2=-1;
      W = getWidth();
      H = getHeight();

      getCursorLoc(x, y, z, flags);
      x0=x;y0=y;

      while (flags&leftButton!=0) {
          getCursorLoc(x, y, z, flags);

          if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
              s = " ";
              if (flags&leftButton!=0 && flags&ctrl==0){
                  Overlay.clear();
                  setColor("yellow");
                  Overlay.drawLine(x0,y0,x,y0);
                  Overlay.show();
                  xl=x0;xr=x;
                  if(xl>xr){xl=x;xr=x0;}
                  bW = xr-xl+1;
                  box = newArray(H*bW);
                  for(j=0;j<H;j++){
                      for(i=0;i<bW;i++){
                          box[j*bW+i]=getPixel(xl+i,j);
                      }
                  }
                  startx = xl;
              }
              if (flags&rightButton!=0) s = s + "<right>";
              if (flags&shift!=0) s = s + "<shift>";
              if (flags&ctrl!=0){
                  for(j=0;j<H;j++){
                      for(i=0;i<bW;i++){
                          v = box[j*bW+i];
                          k = 1-0.1*exp(-(i-bW/2)*(i-bW/2)/(2*bW/3*bW/3));
                          setPixel(startx+i,j,v*k);
                      }
                  }
              if (flags&alt!=0) s = s + "<alt>";
              //print(x+" "+y+" "+z+" "+flags + "" + s);
              //logOpened = true;
              /***********************/


              /***********************/
              
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(10);

      }
 }