// ---- Organoid/Colony Analyzer (refactor of your macro) ----
setBatchMode(true);

// --- Open image & remember names ---
open();
origTitle = getTitle();
fn = getInfo("image.filename");
base = File.nameWithoutExtension(fn);

// --- Ensure grayscale working copy (from green channel if RGB) ---
run("Duplicate...", "title=work");
selectWindow("work");
if (bitDepth==24) {
    // RGB image: split once, take green
    run("Split Channels");
    // Grab the middle channel by discovering windows containing "work"
    // (Works for both "C2-work" and "work (green)")
    greenWin = findLike("work (green)", "C2-work");
    selectWindow(greenWin);
    run("Duplicate...", "title=work");
    // close the three channel windows
    closeLike("work (red)");
    closeLike("work (green)");
    closeLike("work (blue)");
}
run("8-bit");

// --- Pre-filter (Gaussian or Median) ---
run("Gaussian Blur...", "sigma=5"); // your choice; try Median if salt-and-pepper

// --- Edge assist (optional). If you want pure thresholding, comment this block ---
useEdges = false;
if (useEdges) {
    run("Find Edges");
    // Light smoothing to ease thresholding after edges
    run("Gaussian Blur...", "sigma=1.5");
}

// --- Threshold -> Binary (choose one method) ---
method = "MaxEntropy";  // your original choice
setAutoThreshold(method + " dark no-reset");
run("Convert to Mask");

// --- Fill & (optional) erode to clean boundaries ---
run("Fill Holes");
erodeIters = 0; // set 1..2 if needed
for (i=0; i<erodeIters; i++) run("Erode");

// --- Calibrate if needed (so size is in µm² instead of pixels) ---
getPixelSize(unit, pw, ph, pd);
if (pw==0) run("Set Scale...", "distance=1 known=1 unit=pixel global"); // keep pixels; change 'known' & 'unit' if you know µm/pixel

// --- Analyze Particles ---
run("Set Measurements...", "area feret fit shape centroid display redirect=None decimal=3");
sizeStr = "1000-Infinity";   // your original threshold in *current units*
circStr = "0.20-1.00";       // if you want circularity filter, keep this
run("Analyze Particles...", "size="+sizeStr+" circularity="+circStr+" show=Outlines display exclude summarize add");

// --- Output selection ---
outDir = getDirectory("Output folder for results");
if (outDir=="") outDir = getDirectory("home");

// Save outlines (Bulk-Edges analogue)
if (isOpen("Drawing of "+origTitle)) selectWindow("Drawing of "+origTitle);
else if (isOpen("Drawing of work")) selectWindow("Drawing of work");
else selectWindow("work"); // fallback (binary)
saveAs("PNG", outDir + base + "_Bulk-Edges.png");

// Save original
selectWindow(origTitle);
saveAs("PNG", outDir + base + "_Org.png");

// Save results table
if (isOpen("Results")) {
    saveAs("Results", outDir + base + "_Results.csv"); // easier than .xls
}

// --- Tidy up ---
closeAll();
setBatchMode(false);

// -------- helper functions --------
function findLike(pref1, pref2) {
    // returns first open window matching either name pattern
    list = getList("window.titles");
    for (i=0; i<list.length; i++) {
        if (indexOf(list[i], pref1)>=0 || indexOf(list[i], pref2)>=0) return list[i];
    }
    return "";
}
function closeLike(namePart) {
    list = getList("window.titles");
    for (i=0; i<list.length; i++) if (indexOf(list[i], namePart)>=0) { selectWindow(list[i]); run("Close"); }
}
function closeAll() {
    list = getList("window.titles");
    for (i=0; i<list.length; i++) { selectWindow(list[i]); run("Close"); }
}
