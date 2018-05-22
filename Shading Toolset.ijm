/**********************************************************************

Macro Toolset: to do shading correction
refer to : https://github.com/zhouchunyuan/shadingCorrection_MoveStage

***********************************************************************/
    var viewSize = 300;
    var imageSize = 512;
    var addNoise = false;
    var centerIntensity = 4095;
    var intensityAtCorner = 0.5;
    
    macro "visualize Action Tool - C999F00ffCaaaF3399CeeeF5544C037P134272a2d30O15c4" {
        /*******************
        This macro is to visualize the "shadingSample.txt"
        *******************/
        str = getDataString();
        size = countLine(str);
        X = newArray(size);
        Y = newArray(size);
        Z = newArray(size);
        pxy = newArray(size);//calculated parameter

        /******** to get arrays **************/
        start=0;end=0;
        for(i=0;i<size;i++){
                end = indexOf(str,"\n",start);
                line = substring(str,start,end-1);
                start = end+1;
                
                firstComma = indexOf(line,",");
                secondComma = indexOf(line,",",firstComma+1);
                X[i]= parseFloat(substring(line,0,firstComma));
                Y[i]= parseFloat(substring(line,firstComma+1,secondComma));
                Z[i]= parseFloat(substring(line,secondComma+1,lengthOf(line)));
        }

        picSize = viewSize;
        newImage("intensity map", "16-bit black", picSize , picSize , 1);
        brghtness = 0;
        for(j=0.0;j<picSize ;j++){
                for(i=0.0;i<picSize ;i++){
                        x =i/picSize;y=j/picSize;
                        d2min = 2.0;//max distance is sqrt(2)
                        
                        for(k=0;k<lengthOf(Z);k++){
                                d2 = (x-X[k])*(x-X[k])+(y-Y[k])*(y-Y[k]);
                                if( d2 < d2min ){
                                        d2min=d2;
                                        brightness = Z[k];	
                                }
                                
                        }

                        putPixel(i,j,brightness );
                
                }
        showProgress(j, picSize );
        run("Enhance Contrast", "saturated=0.35");
        }
    }

    macro "fitGaussian Action Tool - C888O00ffC999O00eeCaaaO00ddCbbbO00ccCcccO00bbC037T3d14fT7d14iTbd14t" {
        str = getDataString();
        size = countLine(str);
        X = newArray(size);
        Y = newArray(size);
        Z = newArray(size);
        pxy = newArray(size);//calculated parameter

        /******** to get arrays **************/
        start=0;end=0;
        for(i=0;i<size;i++){
                end = indexOf(str,"\n",start);
                line = substring(str,start,end-1);
                start = end+1;
                
                firstComma = indexOf(line,",");
                secondComma = indexOf(line,",",firstComma+1);
                X[i]= parseFloat(substring(line,0,firstComma));
                Y[i]= parseFloat(substring(line,firstComma+1,secondComma));
                Z[i]= parseFloat(substring(line,secondComma+1,lengthOf(line)));
        }

        /******** to calculate center **************/
        centerx=0;centery=0;
        for(i=0;i<size;i++){
                centerx +=X[i]*Z[i];
                centery +=Y[i]*Z[i];
                sum +=Z[i];
        }
        centerx = centerx/sum;
        centery = centery/sum;

        /******** to calculate params **************/
        for(i=0;i<size;i++){
                pxy[i]=sqrt((X[i]-centerx)*(X[i]-centerx)+(Y[i]-centery)*(Y[i]-centery));
        }

        equation = "y = a*exp(-x*x/(2*b*b))";
        Fit.doFit(equation,pxy,Z);
        Fit.plot;

        amp = Fit.p(0);
        sigma = Fit.p(1);

        picSize = imageSize;
        newImage(" Fitted Gaussian ", "16-bit black", picSize , picSize , 1);

        for(j=0.0;j<picSize ;j++){
                for(i=0.0;i<picSize ;i++){
                x = i/picSize - centerx;
                y = j/picSize - centery;
                pixelValue = amp*exp(-(x*x+y*y)/(2*sigma*sigma));
                putPixel(i,j,pixelValue);
                
                }
        }
        run("Enhance Contrast", "saturated=0.35");
    }

    macro "drawGaussian Action Tool - C888O08f8C999O08e7CaaaO08d6CbbbO08c5CcccO08b4C307G82595e99b300Cf80" {

        B = centerIntensity;
        C = -pow(imageSize/2*sqrt(2),2)/log(intensityAtCorner);
        
        newImage("Gaussian "+intensityAtCorner+" @ corner", "16-bit black", imageSize, imageSize, 1);
        for(j=0;j<imageSize;j++){
        for(i=0;i<imageSize;i++){

                v = B*exp(-pow(i-imageSize/2,2)/C-pow(j-imageSize/2,2)/C);
                putPixel(i,j,v);

        }}
        if(addNoise)run("Add Specified Noise...", "standard=500");
        run("Enhance Contrast", "saturated=0.35");
    }

  var dCmds = newMenu("Settings Menu Tool",
      newArray("Setting","-","About"));
      
  macro "Settings Menu Tool - C037T0e11ST7e09eTce09t" {
       cmd = getArgument();
       if (cmd=="Setting"){
        Dialog.create("Settings");
        Dialog.addSlider("mosaic view size:", 100, 500, viewSize);
        Dialog.addSlider("image size:", 128, 8192, imageSize);
        Dialog.addMessage("Parameters for created gaussian:");
        Dialog.addSlider("max intensity:",10,4095,centerIntensity);
        Dialog.addSlider("intensity at corner:", 0.1, 0.9, intensityAtCorner);
        Dialog.addCheckbox("add noise to created image", addNoise)
        Dialog.show();
        viewSize = Dialog.getNumber();
        imageSize = Dialog.getNumber();
        centerIntensity = Dialog.getNumber();
        intensityAtCorner = Dialog.getNumber();
        addNoise = Dialog.getCheckbox();
        }
       else if (cmd=="About"){
        showMessage("About", "<html>"
        +"<h1>Shading Correction Tool</h1>"
        +"<ul>"
        +"<li>This macro can read shading information created by <u>NIS-Elements</u>"
        +"<li>Refer to <u>https://github.com/zhouchunyuan/shadingCorrection_MoveStage</u> for further information"
        +"<li>2018.05.19"
        +"</ul>");
        }
  }

/**********functions******************/ 
/****************************/
function getDataString(){
	unistr = File.openAsRawString("");
	str="";
	for(i=0;i<lengthOf(unistr);i++){
		code = charCodeAt(unistr,i);
		if(code!=0)str+=fromCharCode(code);
	}
	return str;
}

/***************************/
function countLine(str){
	number = 0;
	start = 0;
	end =0;
	
	do{
		end = indexOf(str,"\n",start);
		start = end+1;
		number++;
	}while(start < lengthOf(str))
	if(end==-1)number--;
	return number;
}
