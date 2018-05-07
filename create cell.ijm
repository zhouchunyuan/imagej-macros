/******************************
* generate a 2 channel 10 frame timelapse
* Nucli(DAPI)-Focci(FITC)
* This can be used in JOBs simulator
*******************************/
framenumber = 10;
imageSize = 512*2;
cellnumber = 100;
cellsize = imageSize / sqrt(cellnumber) *0.5;

dotPerCell = 10;
dotSize = cellsize / dotPerCell *0.5;
dotNumber = dotPerCell*cellnumber*2;

newImage("Untitled", "8-bit black", imageSize , imageSize , framenumber*2);

for( frame=0;frame<framenumber;frame++){
        setSlice(frame*2+1);
        for(i=0;i<cellnumber;i++){
        w = (random()*0.4+0.6)*cellsize;
        h = (random()*0.4+0.6)*cellsize;
        x = random()*imageSize;
        y = random()*imageSize;
        makeOval(x,y,w,h);
        setColor(100,100,100);
        run("Fill", "slice");
        }

        setSlice(frame*2+2);

        for(i=0;i<dotNumber;i++){
        w = (random()*0.4+0.6)*dotSize;
        h = (random()*0.4+0.6)*dotSize;
        x = random()*imageSize;
        y = random()*imageSize;
        makeOval(x,y,w,h);
        setColor(200,200,200);
        run("Fill", "slice");
        }
}
run("Make Composite", "display=Composite");

