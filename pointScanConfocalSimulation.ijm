width = 512;
height = 512;
PSF_WIDTH = width/5;
sigma = PSF_WIDTH/6;

I = 65535;// initail intensity
title = "confocal simulator";
/***********************************
 if we set pinhole = 1 AU, 
 the two dots will appear to
 merge at 0.4 AU distance

 if we set pinhole = 0.1 AU,
 two peaks can be seen even we
 we move them as close as 0.28 AU
***********************************/
pinholeSizeFactor = 1;//0.1 - 1
distanceFactor = 0.4;// 0.28 - 0.4

distance = floor(PSF_WIDTH*distanceFactor);//distance between two dots
offset = 0;// center offset of these dots

// if pinhole larger,attenuation should be smaller
// and if distance closer, also attenuation should be smaller 
attenuationFactor = 0.008/pinholeSizeFactor*distanceFactor;

newImage(title, "16-bit black", 512, 512, 1);

illum = newArray(width);
fluo = newArray(width);
detect = newArray(width);

p1 = floor(width/2)-floor(distance/2) + offset;
p2 = floor(width/2)+floor(distance/2) + offset;

for(illum_center = 0; illum_center< width-100; illum_center++){ 
    // create illumination array
    for(i=0;i<width;i++){
        x = (i-illum_center)/PSF_WIDTH*2*4.5;
        //illum = I*exp(-(i-illum_center)*(i-illum_center)/(2*sigma*sigma));
        illum[i] = I*Airy(x);

        setPixel(i,height/2,illum[i]);
    }
    // create fluorescent array
    for(i=0;i<width;i++){
        x1 = (i-p1)/PSF_WIDTH*2*4.5;
        x2 = (i-p2)/PSF_WIDTH*2*4.5;
        I1 = illum[floor(p1)];// illumination intensity for p1
        I2 = illum[floor(p2)];// illumination intensity for p2
        fluo[i] = I1*Airy(x1)+I2*Airy(x2);
        setPixel(i,height/2+10,fluo[i]);
    }
    // create center detector array
    AU = PSF_WIDTH*pinholeSizeFactor ;
    detect_pos = illum_center;
    signal = 0;
    for(i=detect_pos-AU/2;i<detect_pos+AU/2;i++){
        if(i<0)
            signal +=fluo[0];
        else if(i>=width)
            signal +=fluo[width-1];
        else
            signal +=fluo[i];
    }
    detect[detect_pos] = signal*attenuationFactor ;
    setPixel(detect_pos,height/2+50,detect[detect_pos]);

    // create shifted detector array
    /*********************************
      here we simulate a PMT located
      an bias-distance away from the center.
      We can see, a shifted PMT can increase 
      resolution, but decrease the intensity.
     *********************************/
    bias_distance = PSF_WIDTH*0.5;
    detect_pos = illum_center + bias_distance;
    signal = 0;
    for(i=detect_pos-AU/2;i<detect_pos+AU/2;i++){
        if(i<0)
            signal +=fluo[0];
        else if(i>=width)
            signal +=fluo[width-1];
        else
            signal +=fluo[i];
    }
    detect[illum_center] = signal*attenuationFactor ;
    setPixel(detect_pos,height/2+100,detect[illum_center]);    
    updateDisplay();
    //wait(10);
}
profileAt = height/2+50;
makeLine(0,profileAt ,width,profileAt );
run("Plot Profile");
selectWindow(title);
profileAt = height/2+100;
makeLine(0,profileAt ,width,profileAt );
run("Plot Profile");


/******************************************************
# Since there is no Bessel function in Imagej macro,
# I have to use j1 = sin(x)/(x*x)-cos(x)/x to simulate
# Bessel first kind first order J1
# Scale factor of 1.14 in x, and 2.25 in y is found by
# python 3.6:

import numpy as np
import pylab as py
import scipy.special as sp

def airy(x):
    f = 1.14
    a = np.sin(x*f)/((x*f)**2)-np.cos(x*f)/(x*f)
    return 2.25*((2*a/(x*f))**2)

x = np.linspace(-10, 10, 2000)
py.plot(x, (2*sp.j1(x)/x)**2,'r--',x, airy(x),'b--')

py.xlim((-10, 10))
py.ylim((-0.5, 1.1))
py.legend(('$(2\mathcal{J}_1(x)/x)^2$','$2.25[(sin(x)/x^2-cos(x)/x)/x]^2$'))
py.xlabel('$x$')
py.ylabel('Intensity')
py.grid(True)
                                     
py.show()
*******************************************************/
function Airy(x){
    factor = 1.14;
    m = 2.25;
    fx = factor*x;
    if(fx==0){
        ret = 1;
    }else{
        j1 = sin(fx)/(fx*fx)-cos(fx)/fx;
        ret = m*(2*j1/fx)*(2*j1/fx);
    }
    return ret;
}

