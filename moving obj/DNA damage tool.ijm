// This macro tool shows 4 buttons 
// 1) button1 "copy", duplicate and split a color stack
// 2) button2 "proc", does blur and open the threshold GUI
// 3) button3 "auto", before click this button, we need to select the "starting recovery frame"
//    by manual click the Wand tool, we specify the starting ROI.
//    The macro will copy the current ROI into the range of [1~current],
//    and track through all "later frames" until the end
// 4) button4 "curv", before using this button, remember to select the original stack.
//    The macro will apply ROIs from roimanager to current stack, and draw a curve plot.
// 
//   see a screen shot jpg <DNA damage Tool.jpg>

var radius = 10;
    macro "Unused Tool - C037" { }

    macro "Copy Image and split color Action Tool - C037T0d10cT4d10oT8d10pTcd10y" {
        if (nImages==0) {
            showMessage("Copy Image", "The \"DNA damage Tools\" macros require a stack");
            return;
        }
        run("Duplicate...", "duplicate");
        run("Split Channels");
    }

    macro "Blur and please make binary Action Tool - C037T0d10pT6d10rT8d10oTed10c" {
        run("Gaussian Blur...", "sigma=2 stack");
        run("Threshold...");
        setThreshold(1000, 65535);
    }

    macro "Select the first recover frame, and use Wand Action Tool - C037T0d10aT5d10uTbd10tTed10o" {
        if(roiManager("count")!=0)roiManager("Delete");

        currentFrame = getSliceNumber();
        n = currentFrame;
        results = newArray(nSlices);
        var xpoints0;
        var ypoints0;
        getSelectionCoordinates(xpoints0, ypoints0);

        for(n=1;n<currentFrame;n++){
                setSlice(n);
                makeSelection("freehand", xpoints0, ypoints0);
                getStatistics(area, mean);
                results[n-1]=mean;
                roiManager("Add");
        }

        while(n<=nSlices){
                setSlice(n);
                getSelectionCoordinates(xpoints, ypoints);
                Array.getStatistics(xpoints, min, max, Xmean, stdDev);
                Array.getStatistics(ypoints, min, max, Ymean, stdDev);
                if(getPixel(Xmean,Ymean)!=0){
                        doWand(Xmean,Ymean);
                        getStatistics(area, mean);
                        results[n-1]=mean;
                        roiManager("Add");
                        n++;
                }else{
                        exit;
                }
        }

    }

    macro "draw curve Action Tool - C037T0d10cT5d10uTbd10rTed10v" {
        count = roiManager("count");
        yValue = newArray(count);
        for(i=0;i<count;i++){
        roiManager("select", i);
        getStatistics(area, yValue[i]);
        }
        Plot.create("DNA damage curve","time","intensity",yValue);
    }
