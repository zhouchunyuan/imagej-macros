/*

1����DAPI��Redͼ
2��ͨ��Redͼѡ������RED_PERCENT%������ROI
3��ͨ��DAPIͼ��ѡ������BLUE_PERCENT%���ɶ�����ͼ.
4�����ڴ���MAX_AREA��ROI���������Fill 0��
�˺�
  5��ѡȡ��ɫ�����Ĳ���ΪmaskRed
  6��ѡȡ��ɫ�˵Ĳ���maskBlue
  7����maskBlue��������maskBlueMargin ��0��ʾ�����󣩣�����maskRed-maskBlue
  8) ��ch1��ȥ��7���Ľ�����������ֲ���maskBlue������Χ�ڵĲ��ֱ�ȥ����

*/
RED_PERCENT = 0.015;
BLUE_PERCENT = 0.1;
BINARY_BRIGHTNESS = 45;
maskBlueMargin = 10;
MAX_AREA = 0.01;

dir = getDirectory("Choose a Directory ");
list = getFileList(dir);
for (i=0; i<list.length; i+=2) {
    ch1 = list[i];ch2 = list[i+1];
    open(dir + ch1);
    run("Split Channels");
    selectWindow(ch1+" (green)");
    close();
    selectWindow(ch1+" (blue)");
    close();
    open(dir + ch2);
    run("Split Channels");
    selectWindow(ch2+" (green)");
    close();
    selectWindow(ch2+" (red)");
    close();

    process(ch1+" (red)",ch2+" (blue)");

//run("Merge Channels...", "c1=["+ch1+" (red)] c3=["+ch2+" (blue)] create");
//rename(ch1);
    selectWindow(ch2+" (blue)");
    close();
    run("Red");
    saveAs("Tiff", dir+ch1+"_copy.tif");

}

function process(ch1,ch2){
    selectWindow(ch1);
    run("Duplicate...", " ");
    rename("maskRed");
    getStatistics(area, mean, min, max, std, histogram);

    SUM = 0;sum = 0;
    for(i=0;i<histogram.length;i++)SUM+=histogram[i];
    for(i=histogram.length-1;i>=0;i--){
        sum+=histogram[i];
        if(sum/SUM > RED_PERCENT)break;
    }

    setThreshold(i, max);
    run("Convert to Mask");

    // **** modify the binary
    run("Options...", "iterations=1 count=3");
    run("Dilate");// expand a little

    run("Watershed");
    run("Analyze Particles...", "  show=Nothing clear add");
    //close("maskRed");

    /*************** select DAPI *****************/
    selectWindow(ch2);
    run("Duplicate...", " ");
    rename("maskBlue");
    getStatistics(area, mean, min, max, std, histogram);
    SUM = 0;sum = 0;
    for(i=0;i<histogram.length;i++)SUM+=histogram[i];
    for(i=histogram.length-1;i>=0;i--){
        sum+=histogram[i];
        if(sum/SUM > BLUE_PERCENT)break;
    }
    run("Clear Results");
    setThreshold(i, max);
    run("Convert to Mask");

    // **** modify the binary
    //run("Dilate");// expand a little

    run("Set Measurements...", "area mean integrated redirect=None decimal=3");
    roiManager("Measure");
    //close("maskBlue");

    /***************** remove large **************/
    large= 0;
    for(i=0;i<nResults;i++){
        v = getResult("Area", i);
        if(v>MAX_AREA)large++;
    }
    idxArray = newArray(large); // to store large results list
    n = 0;
    for(i=0;i<nResults;i++){
        v = getResult("Area", i);
        if(v>MAX_AREA){
             idxArray[n]=i;
             n++;
        }
    }
    roiManager("select", idxArray);// select all large Rois

    /*************** select Red and clear Rois *****************/
    selectWindow(ch1);
    setForegroundColor(0, 0, 0);

    roiManager("Fill");// this might be a bug
    roiManager("Fill");// both "Fill" are needed. otherwise imcomplete fill.

    /************* further process binary ***************/
    selectWindow("maskBlue");
    run("Select None");
    if(maskBlueMargin >0){
        run("Options...", "iterations=" + maskBlueMargin +" count=1");
        run("Dilate");// expand 5 pixels
    }
    imageCalculator("Subtract create", "maskRed","maskBlue");
    imageCalculator("Subtract create", ch1,"Result of maskRed");
    close("maskRed");
    close("maskBlue");
    close("Result of maskRed");
    close(ch1);

    rename(ch1);
}
