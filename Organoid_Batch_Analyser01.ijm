open();

fn=getTitle(); //gets image title
name = getInfo("image.filename")

run("Duplicate...", "title=Image duplicate");

run("Split Channels");
selectWindow("C1-Image");
run("Duplicate...", "title=RedOrig duplicate");
close();
selectWindow("C1-Image");
close();

selectWindow("C2-Image");
run("Duplicate...", "title=GreenOrig duplicate");
selectWindow("C2-Image");
close();

selectWindow("C3-Image");
run("Duplicate...", "title=BlueOrig duplicate");
close();
selectWindow("C3-Image");
close();

selectWindow("GreenOrig");

run("Duplicate...", "title=GreenThreshLoc duplicate");
run("8-bit");
run("Duplicate...", "title=GreenThresh duplicate");
setOption("ScaleConversions", true);
run("8-bit");
run("Gaussian Blur...", "sigma=5");

selectWindow("GreenThresh");
run("Invert");
run("Duplicate...", "title=Bulk-Edges");
setAutoThreshold("MaxEntropy dark no-reset"); 
//run("Threshold...");
setThreshold(141, 255, "raw");
run("Convert to Mask");
run("Find Edges");
run("Analyze Particles...", "size=1000-Infinity pixel show=Outlines display exclude summarize add");
//run("Analyze Particles...", "size=600-Infinity pixel circularity=0.00-1.00 show=Outlines display exclude summarize add");
////////////////////////////////////////////////
selectWindow("Drawing of Bulk-Edges");
run("Close");
selectWindow(fn);
roiManager("Show None");
roiManager("Show All");
selectWindow("GreenOrig");
run("Close");
selectWindow("GreenThresh");
selectWindow("GreenThreshLoc");
run("Close");
selectWindow("ROI Manager");
run("Close");

output = getDirectory("Output folder for results"); //get output folder
selectWindow("Bulk-Edges");
Image_Result = output + fn + "Bulk-Edges";
saveAs("png",Image_Result);
selectWindow (fn);
Image_Org = output + fn +"Org.png";
saveAs("png",Image_Org);
Res_out = output + fn + "Res.xls";
saveAs ("Results", Res_out);
