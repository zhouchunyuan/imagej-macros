/*
 1) copy all images into a CLEAN folder (do not put macro here!)
 2) run this macro. This will create a "new" folder
 3) all combined images will be saved in "new" folder
*/
dir = getDirectory("Choose a Directory ");
list = getFileList(dir);
File.makeDirectory(dir+"\\new");
for (i=0; i<list.length; i+=2) {
    open(dir + list[i]);
    run("Split Channels");
    selectWindow(list[i]+" (green)");
    close();
    selectWindow(list[i]+" (blue)");
    close();
    open(dir + list[i+1]);
    run("Split Channels");
    selectWindow(list[i+1]+" (green)");
    close();
    selectWindow(list[i+1]+" (red)");
    close();
    run("Merge Channels...", "c1=["+list[i]+" (red)] c3=["+list[i+1]+" (blue)] create");
    saveAs("Tiff", dir+"\\new\\"+list[i]);
    close();
}
