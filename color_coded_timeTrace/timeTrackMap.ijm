
str = getDataString();

size = countLine(str);

X = newArray(size-1);
Y = newArray(size-1);
Z = newArray(size-1);


/******** to get arrays **************/
start=0;end=0;
for (i=0;i<size;i++) {
    end = indexOf(str,"\n",start);
    line = substring(str,start,end-1);
    start = end+1;

    if (i!=0) {
        firstComma = indexOf(line,",");
        secondComma = indexOf(line,",",firstComma+1);
        thirdComma = indexOf(line,",",secondComma+1);

        X[i-1]= parseFloat(substring(line,0,firstComma));
        Y[i-1]= parseFloat(substring(line,firstComma+1,secondComma));
        if (thirdComma != -1)
            timeStr = substring(line,secondComma+1,thirdComma);
        else
            timeStr = substring(line,secondComma+1);

        Z[i-1] = getSeconds(timeStr);

    }
}

/**** calculate graph size and aspect ratio*****/

Array.getStatistics(X, min_x, max_x, mean, stdDev);
Array.getStatistics(Y, min_y, max_y, mean, stdDev);
wx = max_x - min_x;
ht = max_y - min_y;

newImage("Untitled", "16-bit black", 512, ht/wx*512, 1);

/********* draw the time color line *****/
setLineWidth(2);
for (i=0;i<size-1;i++) {
    x = (X[i]-min_x)*512.0/wx;
    y = (Y[i]-min_y)*512.0/wx;
    setColor(Z[i]);
    if (i==0)
        drawLine(x,y,x,y);
    else
        lineTo(x,y);
}

/********* create heat map ******/
Array.getStatistics(Z, min_z, max_z, mean, stdDev);
x0 = 10;
x1 = 512/20+x0;
scaleY0 = 30;
scaleLines = 100;
y = scaleY0 ;
dz = (max_z-min_z)/scaleLines ;
for ( z = min_z; z<=max_z; z+=dz) {
    setColor(z);
    drawLine(x0,y,x1,y);
    y++;
}

Overlay.remove;
fontSize = 14;
setFont("SanSerif", fontSize , "antialiased");
setColor("black");
Overlay.drawString(""+min_z+" sec", x1+5,scaleY0 +10+fontSize/2);
Overlay.drawString(""+max_z+" sec", x1+5,scaleY0 +scaleLines );

Overlay.drawString("("+min_x+","+min_y+")", 0,10+fontSize/2);
Overlay.drawString("("+max_x+","+max_y+")", 512 - 100,ht/wx*512);
Overlay.show();

/******* set LUT *******/
run("Spectrum");
getLut(reds, greens, blues);
reds[0]=255;
greens[0]=255;
blues[0]=255;
setLut(reds, greens, blues);







/**********functions******************/
/****************************/
function getDataString() {
    unistr = File.openAsRawString("",100000);
    str="";
    for (i=0;i<lengthOf(unistr);i++) {
        code = charCodeAt(unistr,i);
        if (code!=0)str+=fromCharCode(code);
    }
    return str;
}

/***************************/
function countLine(str) {
    number = 0;
    start = 0;
    end =0;

    do {
        end = indexOf(str,"\n",start);
        start = end+1;
        number++;
    } while (start < lengthOf(str))
        if (end==-1)number--;
    return number;
}

/***************************/
function getSeconds(str) {
    firstColon = indexOf(str,":");
    secondColon = indexOf(str,":",firstColon+1);
    if (secondColon !=-1) {
        h= parseFloat(substring(str,0,firstColon));
        m= parseFloat(substring(str,firstColon+1,secondColon));
        s= parseFloat(substring(str,secondColon+1,lengthOf(str)));
    } else {
        m= parseFloat(substring(str,0,firstColon));
        s= parseFloat(substring(str,firstColon+1));
        h= 0;
    }
    return s+m*60+h*3600;
}

