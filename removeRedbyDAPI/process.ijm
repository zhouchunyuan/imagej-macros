/*

1����DAPI��Redͼ
2��ͨ��Redͼѡ������2%������ROI
3��ͨ��DAPIͼ��ѡ������10%���ɶ�����ͼ.
4���޳�����DAPI������ͼ�����Ⱦ�ֵ��mean������200��ROI
5����ʣ�µ�ROI����ͼ�����㡣

�������׷�����������������2%��10%��200.

���⣬����������������ͳ��ѧ�ϵ�ͨ���ԣ�һ�㲻��׷��������

History: 
20181225: �Ժ�ͨ������dilate
20190103: 
  1��ѡȡ��ɫ�����Ĳ���ΪmaskRed
  2��ѡȡ��ɫ�˵Ĳ���maskBlue
  3����maskBlue�������أ�����maskRed-maskBlue
  4) ��ch1��ȥ��3���Ľ�����������ֲ���maskBlue������Χ�ڵĲ��ֱ�ȥ����
*/
RED_PERCENT = 0.015;
BLUE_PERCENT = 0.1;
BINARY_BRIGHTNESS = 45;
maskBlueMargin = 5;

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

    nonZero = 0;
    for(i=0;i<nResults;i++){
        v = getResult("Mean", i);
        if(v>BINARY_BRIGHTNESS)nonZero++;
    }
    idxArray = newArray(nonZero); // to store non-zero results list
    n = 0;
    for(i=0;i<nResults;i++){
        v = getResult("Mean", i);
        if(v>BINARY_BRIGHTNESS){
             idxArray[n]=i;
             n++;
        }
    }
    roiManager("select", idxArray);// select all non-zero Rois
    roiManager("delete");          // and delete them

    /*************** select Red and clear Rois *****************/
    selectWindow(ch1);
    setForegroundColor(0, 0, 0);
    roiManager("Deselect");
    roiManager("Fill");// this might be a bug
    roiManager("Fill");// both "Fill" are needed. otherwise imcomplete fill.

    /************* further process binary ***************/
    selectWindow("maskBlue");
    run("Options...", "iterations=" + maskBlueMargin +" count=1");
    run("Dilate");// expand 5 pixels
    imageCalculator("Subtract create", "maskRed","maskBlue");
    imageCalculator("Subtract create", ch1,"Result of maskRed");
    close("maskRed");
    close("maskBlue");
    close("Result of maskRed");
    close(ch1);

    rename(ch1);

}
