run("Remove Overlay");
setColor("white");
/*
start = 1; 
index = 0; 
while (start<=nSlices) { 
     range = ""+start+"-"+(start);

     sec = floor(index*0.033);
     ms = round((index*33%1000)/10); 
     label = ""+sec+" sec "+ms; 
     run("Label...", "format=Text x=50 y=10 font=20 text=&label range=&range use"); 
     start += 1; 
     index++; 
} 
*/
for(i=1;i<=nSlices;i++){
    range = ""+i+"-"+i;
    timeIndex = i-1;
     sec = floor(timeIndex *0.033);
     ms = round((timeIndex *33%1000)/10); 
     label = ""+sec+" sec "+ms; 
     run("Label...", "format=Text x=50 y=10 font=20 text=&label range=&range use"); 
}
