/******* open file ****************/
path = File.openDialog("Select a File");
length=File.length(path);
unistr = File.openAsRawString(path,length);
str="";
for (i=0;i<lengthOf(unistr);i++) {
    code = charCodeAt(unistr,i);
    if (code!=0)str+=fromCharCode(code);
}

/****** count line number *********/
lines = split(str,"\n");
size = lines.length;

/****** find column separater ****/
var spliter = ",";
choice = split(lines[0],spliter);
if(choice.length<3){
    spliter = "\t";
    choice = split(lines[0],spliter);
}

Dialog.create("Choose Columns");
Dialog.addChoice("positionX:", choice,choice[0]);
Dialog.addChoice("positionY:", choice,choice[1]);
Dialog.addChoice("time:", choice,choice[2]);
Dialog.addRadioButtonGroup("time format", newArray("0.00(s)","00:00:00"), 1, 2, "0.00(s)");
Dialog.addNumber("MSD n number",50);
Dialog.show();
chx = Dialog.getChoice();
chy = Dialog.getChoice();
cht = Dialog.getChoice();
timeFormat = Dialog.getRadioButton();
msdNumber = Dialog.getNumber();

X = newArray(size-1);
Y = newArray(size-1);
Z = newArray(size-1);

/**** to find out column indices ****/
var col_x,col_y,col_t;
for(i=0;i<choice.length;i++){
    if(chx==choice[i])col_x=i;
    else if(chy==choice[i])col_y=i;
    else if(cht==choice[i])col_t=i;
}

for(i=1;i<size;i++){
    dataline = split(lines[i],spliter);
    X[i-1]=parseFloat(dataline[col_x]);
    Y[i-1]=parseFloat(dataline[col_y]);
    if(timeFormat=="00:00:00")
        Z[i-1]=getSeconds(dataline[col_t]);
    else
        Z[i-1]=parseFloat(dataline[col_t]);
}

/**** calculate graph size and aspect ratio*****/

Array.getStatistics(X, min_x, max_x, mean, stdDev);
Array.getStatistics(Y, min_y, max_y, mean, stdDev);
wx = max_x - min_x;
ht = max_y - min_y;

// with = 512, 100 is the scale range
newImage("Untitled", "16-bit black", 512+100, ht/wx*512, 1);

/********* draw the time color line *****/
setLineWidth(2);
for (i=0;i<size-1;i++) {
    x = (X[i]-min_x)*512.0/wx;
    y = (Y[i]-min_y)*512.0/wx;
    setColor(Z[i]-Z[0]);
    if (i==0)
        drawLine(x,y,x,y);
    else
        lineTo(x,y);
}

/********* create heat map ******/
Array.getStatistics(Z, min_z, max_z, mean, stdDev);
x0 = 512+10;
x1 = 512/20+x0;
scaleY0 = 30;
scaleLines = getHeight()-scaleY0-30;
y = scaleY0 ;
dz = (max_z-min_z)/scaleLines ;
for ( z = min_z; z<=max_z; z+=dz) {
    setColor(z-min_z);
    drawLine(x0,y,x1,y);
    y++;
}

/***** draw captions ***********/
Overlay.remove;
fontSize = 14;
setFont("SanSerif", fontSize , "antialiased");
setColor("black");
Overlay.drawString(""+0+" sec", x1+5,scaleY0 +10+fontSize/2);
Overlay.drawString(""+(max_z-min_z)+" sec", x1+5,scaleY0 +scaleLines );

Overlay.drawString("("+min_x+","+min_y+")", 0,10+fontSize/2);

outStr = "("+max_x+","+max_y+")";
strWidth = getStringWidth(outStr);
Overlay.drawString(outStr, 512 - strWidth,ht/wx*512);

/*********** show MSD *************/
    // average on msdNumber frames

    m = (size-1) - msdNumber - 1;
    sum = 0;
    for(i=0;i<m;i++){
        //t0 = T[i];
        //t1 = T[n+i];
        sum += (X[msdNumber +i]-X[i])*(X[msdNumber +i]-X[i])
               +(Y[msdNumber +i]-Y[i])*(Y[msdNumber +i]-Y[i]);
    }
    msd = sum/m;
    msdStr = "MSD: "+msd+" um2/frame";
Overlay.drawString(msdStr, getWidth()-getStringWidth(msdStr), 20);
/*********************************/
Overlay.show();

/******* set LUT *******/
run("Spectrum");
getLut(reds, greens, blues);
getLut(newreds, newgreens, newblues);//to do newArray instead...

start = 20;end = 230;
lut_range = end-start;
for(i=0;i<256;i++){
    newlut = parseInt(i/256.0*lut_range)+start; 
    newreds[i]=reds[newlut];
    newgreens[i]=greens[newlut];
    newblues[i]=blues[newlut];
}

newreds[0]=255;newgreens[0]=255;newblues[0]=255;
setLut(newreds, newgreens, newblues);

run("Enhance Contrast", "saturated=0.35");





/**********functions******************/



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

