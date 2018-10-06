width = 512;
height = 512;
PSF_WIDTH = width/5;
sigma = PSF_WIDTH/6;

I = 65535;// initail intensity

/***********************************
 if we set pinhole = 1 AU, 
 the two dots will appear to
 mergeseperated at 0.4 AU distance

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

newImage("Untitled", "16-bit black", 512, 512, 1);

illum = newArray(width);
fluo = newArray(width);
detect = newArray(width);

p1 = floor(width/2)-floor(distance/2) + offset;
p2 = floor(width/2)+floor(distance/2) + offset;

for(illum_center = 0; illum_center< width; illum_center++){ 
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
    // create detector array
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
    
    updateDisplay();
    //wait(10);
}
profileAt = height/2+50;
makeLine(0,profileAt ,width,profileAt );
run("Plot Profile");

function Airy(x){
    if(x==0){
        ret = 1/2.25;
    }else{
        j1 = sin(x)/(x*x)-cos(x)/x;
        ret = (2*j1/x)*(2*j1/x);
    }
    return ret*2.25;
}

