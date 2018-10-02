var width = 512;
var height = 512;
var PSF_width = width/5;//local width PSF_width
var ill_position = height/3;
var ccd_position = height/2;

var sd = PSF_width/6;//define standard deviation

var distanceFactor = 1.0; //unit is AU

var displayContrast = 200/distanceFactor; // after integration, easy to saturate

/****** switches ******/
var SoRa = 0;
var showOutline = 1;
var showDots = 1;
var slowMode = 1;

macro "Unused Tool - C037" { }

macro "Resolution Simulation Action Tool - C037T0d10ST4d10oT8d10RTcd10a" {

    ccdLine = newArray(width);//simulate a ccd line
    for (i=0;i<lengthOf(ccdLine);i++)ccdLine[i]=0;
    distance = PSF_width*distanceFactor;//distance between two fluorescent dots
    dots = newArray(
               width/2-distance/2,
               width/2+distance/2);

    if (SoRa)
        title = "SoRa";
    else
        title = "Normal";
    newImage(title , "16-bit black", width, height, 1);

    for (r=0;r<width;r+=1) {

        /************* illumination PSF *************/
        for (j=ill_position;j<ccd_position;j++)
            for (i=0;i<width;i++) {
                setPixel(i,j,0);
            }//clear

        if (showDots) {
            setColor(30000);
            for (n=0;n<lengthOf(dots);n++) {
                drawLine(dots[n],ill_position-5,dots[n],ill_position+5);
            }
        }

        for (i=r-PSF_width/2;i<=r+PSF_width/2;i++) {
            illum = 65535/displayContrast *exp(-(i-r)*(i-r)/(2*sd*sd));
            setPixel(i,ill_position,illum*displayContrast );

            /*********** draw fluorescent by illumination PSF *****/
            for (n=0;n<lengthOf(dots);n++) {
                i0 = floor(dots[n]);
                if (abs(i-i0)<0.5) {
                    for (ii=floor(i0-PSF_width/2);ii<=i0+PSF_width/2;ii++) {
                        fluo = illum*exp(-(ii-i0)*(ii-i0)/(2*sd*sd));
                        setPixel(ii,ill_position+5 + 2*n,fluo*displayContrast );

                        /**** integrate into CCD pixel ****/
                        if (SoRa)
                            remapIndex = floor((ii-r)/2+r);// 1:2 projection, SoRa way
                        else
                            remapIndex = ii;//1:1 projection
                        ccdLine[remapIndex] +=fluo;// simulate exposure sum

                        setPixel(ii,ccd_position,ccdLine[ii]);
                        if (showOutline) {
                            setColor(10000);
                            //drawLine(ii,ill_position+5+2*n+1,remapIndex,ccd_position-2);
                            starti = floor(i0-PSF_width/2);
                            endi = i0+PSF_width/2;

                            if (SoRa) {
                                drawLine(starti,ill_position+5+2*n+1,(starti-r)/2+r,ccd_position-2);
                                drawLine(endi,ill_position+5+2*n+1,(endi-r)/2+r,ccd_position-2);
                            } else {
                                drawLine(starti,ill_position+5+2*n+1,starti,ccd_position-2);
                                drawLine(endi,ill_position+5+2*n+1,endi,ccd_position-2);
                            }
                        }
                    }
                    if (slowMode)wait(50);
                }
            }
            /*****************************************************/
        }//draw
        /*********************************************/

        updateDisplay();
        if (slowMode)wait(50);
    }

    makeLine(0, ccd_position, width, ccd_position);
    wait(1000);
    run("Plot Profile");
    selectWindow(title);
    run("Select None");

}


/********************* PMT : point scan mode **************************/

macro "PMP Simulation Action Tool - C037T0d10PT6d10MTed10T" {

    distance = PSF_width*distanceFactor;//distance between two fluorescent dots
    dots = newArray(
               width/2-distance/2,
               width/2+distance/2);

    newImage("PMT confocal" , "16-bit black", width, height, 1);
    for (r=0;r<width;r+=1) {
        /************* illumination PSF *************/
        for (j=ill_position;j<ccd_position;j++)
            for (i=0;i<width;i++) {
                setPixel(i,j,0);
            }//clear

        if (showDots) {
            setColor(30000);
            for (n=0;n<lengthOf(dots);n++) {
                drawLine(dots[n],ill_position-5,dots[n],ill_position+5);
            }
        }

        setColor(0);
        fillRect(r-10,ccd_position-30-10,20,20);
        setColor(50000);
        drawOval(r-5,ccd_position-30-5,10,10);
        epiLine = newArray(width);//epi imaging plane
        for (idx=0;idx<lengthOf(epiLine);idx++)epiLine[idx]=0;
        for (i=r-PSF_width/2;i<=r+PSF_width/2;i++) {
            illum = 65535/displayContrast *exp(-(i-r)*(i-r)/(2*sd*sd));
            setPixel(i,ill_position,illum*displayContrast );

            /*********** draw fluorescent by illumination PSF *****/
            for (n=0;n<lengthOf(dots);n++) {
                i0 = floor(dots[n]);
                if (abs(i-i0)<0.5) {
                    for (ii=floor(i0-PSF_width/2);ii<=i0+PSF_width/2;ii++) {
                        fluo = illum*exp(-(ii-i0)*(ii-i0)/(2*sd*sd));
                        setPixel(ii,ill_position+5 + 2*n,fluo*displayContrast );

                        /**** image on epi plane ****/
                        epiLine[ii] +=fluo;// simulate exposure sum
                    }
                    if (slowMode)wait(50);
                }
            }
            /*****************************************************/
        }//draw

        sum = 0;
        gaussianStart = r-PSF_width/2;
        if (gaussianStart<0)gaussianStart=0;
        gaussianEnd = r+PSF_width/2;
        if (gaussianEnd>511)gaussianEnd=511;
        for (i=gaussianStart;i<gaussianEnd;i++) sum += epiLine[i];
        setPixel(r,ccd_position,sum);

        /*********************************************/
        updateDisplay();
        if (slowMode)wait(50);
    }

    makeLine(0, ccd_position, width, ccd_position);
    wait(1000);
    run("Plot Profile");
}

/********************* laser beam mouse move **********************/
macro "Manual Demo Tool - C037T0d10MT6d10OTed10V" {
    leftButton=16;
    rightButton=4;
    shift=1;
    ctrl=2;
    alt=8;
    
    ccdLine = newArray(width);//simulate a ccd line
    
    setColor(0);
    fillRect(0,ill_position-20,width,ill_position+20);
    distance = PSF_width*distanceFactor;//distance between two fluorescent dots
    dots = newArray(
               width/2-distance/2,
               width/2+distance/2);
    setColor(30000);
    for (n=0;n<lengthOf(dots);n++) {
        drawLine(dots[n],ill_position-5,dots[n],ill_position+5);
    }               
    getCursorLoc(x, y, z, flags);
    while (flags&leftButton!=0) {
        for (i=0;i<lengthOf(ccdLine);i++)ccdLine[i]=0;
        getCursorLoc(x, y, z, flags);

        for (i=x-PSF_width/2;i<=x+PSF_width/2;i++) {
             illum = 65535/displayContrast *exp(-(i-x)*(i-x)/(2*sd*sd));
             setPixel(i,ill_position,illum*displayContrast );
             

            /*********** draw fluorescent by illumination PSF *****/
            for (n=0;n<lengthOf(dots);n++) {
                i0 = floor(dots[n]);
                if (abs(i-i0)<0.5) {
                    for (ii=floor(i0-PSF_width/2);ii<=i0+PSF_width/2;ii++) {
                        fluo = illum*exp(-(ii-i0)*(ii-i0)/(2*sd*sd));
                        setPixel(ii,ill_position+5 + 2*n,fluo*displayContrast );
                        ccdLine[ii]+=fluo;
                    }
                }

            }
            /*****************************************************/
        }
        for(i=0;i<width;i++)setPixel(i,ccd_position,ccdLine[i]*displayContrast);
        updateDisplay();
        wait(10);
    }
}

/********************* fluorescent dots and CCD pixel mouse move **********************/
var dotx = width/2;
var detx = width/2;
macro "Move Dots and pixel Demo Tool - C037T0d10DT6d10OTed10T" {
    leftButton=16;
    rightButton=4;
    shift=1;
    ctrl=2;
    alt=8;
    
    
    ccdLine = newArray(width);//simulate a ccd line
    

    distance = PSF_width*distanceFactor;//distance between two fluorescent dots
    dots = newArray(
               width/2-distance/2,
               width/2+distance/2);
    setColor(30000);
    for (n=0;n<lengthOf(dots);n++) {
        drawLine(dots[n],ill_position-5,dots[n],ill_position+5);
    }   

    getCursorLoc(x, y, z, flags);
    while (flags&leftButton!=0) {
        for (i=0;i<lengthOf(ccdLine);i++)ccdLine[i]=0;
        setColor(0);
        fillRect(0,ill_position-20,width,ill_position+20);
        // draw beam
        for (i=width/2-PSF_width/2;i<=width/2+PSF_width/2;i++) {
            illum = 65535/displayContrast *exp(-(i-width/2)*(i-width/2)/(2*sd*sd));
            setPixel(i,ill_position,illum*displayContrast );    
        }
        getCursorLoc(x, y, z, flags);

        setColor(60000);
        if(y<height/2)dotx = x;
        drawLine(dotx,ill_position-5,dotx,ill_position+5);
        if(y>height/2)detx = x; 
        drawOval(detx-5,ccd_position+10 -5,10,10);        

            /*********** draw fluorescent by illumination PSF *****/
        illum = 65535/displayContrast *exp(-(dotx-width/2)*(dotx-width/2)/(2*sd*sd)); 
        for (ii=0;ii<width;ii++){ 
            fluo = illum*exp(-(ii-dotx)*(ii-dotx)/(2*sd*sd));
                        setPixel(ii,ill_position+5 + 2*n,fluo*displayContrast );
                        ccdLine[ii]=fluo;
        }

            /*****************************************************/
    for(i=0;i<width;i++)setPixel(i,ccd_position,ccdLine[i]*displayContrast);
    setColor(ccdLine[detx]*displayContrast);
    drawLine(dotx,ccd_position+100 -5,dotx,ccd_position+100 +5); 
    
    updateDisplay();
    wait(50);
    }

}
    /************************ parameters *************************/

    var dCmds = newMenu("Settings Menu Tool",
                        newArray("Setting","-","About"));

    macro "Settings Menu Tool - C037T0e11ST7e09eTce09t" {

        cmd = getArgument();

        if (cmd=="Setting") {

            Dialog.create("Settings");

            Dialog.addSlider("2 dots distance (AU):", 0.1, 3.0, distanceFactor);

            Dialog.addMessage("Parameters for created gaussian:");

            Dialog.addCheckbox("Insert SoRa lens", SoRa)

            Dialog.addCheckbox("Slow Mode", slowMode)

            Dialog.show();

            distanceFactor = Dialog.getNumber();

            SoRa = Dialog.getCheckbox();

            slowMode = Dialog.getCheckbox();
        }

        else if (cmd=="About") {

            showMessage("About", "<html>"

                        +"<h1>SoRa simulation tool</h1>"

                        +"<ul>"

                        +"<li>This macro is to explain how SoRa super resolution microscope works"

                        +"<li>Refer to the following paper [Super-resolution spinning-disk confocal microscopy using optical photon reassignment]"

                        +"<li>2018.10.01"

                        +"</ul>");

        }

    }
