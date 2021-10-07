hcube= hypercube('SUBSET FINAL.hdr');
%% Estimate an RGB color image from the data cube by using the colorize function. Set the ContrastStretching parameter value to true in order to improve the contrast of RGB color image. Display the RGB image.
rgbImg = colorize(hcube,'Method','rgb','ContrastStretching',true);
figure
imshow(rgbImg)
title('RGB Image')
%% Read Reference Spectra
%%Read the spectral information corresponding to a roofing material from the ECOSTRESS spectral
%% library by using the readEcostressSig function.
%%Add the full file path containing the ECOSTRESS spectral file
fileroot = matlabshared.supportpkg.getSupportPackageRoot();
addpath(fullfile(fileroot,'toolbox','images','supportpackages','hyperspectral','hyperdata','ECOSTRESSSpectraFiles'));
lib = readEcostressSig("manmade.roofingmaterial.metal.solid.all.0692uuucop.jhu.becknic.spectrum.txt");
%%Inspect the properties of the referece spectra read from the ECOSTRESS library.
lib

%%Read the wavelength and the reflectance values stored in lib. The wavelength and the reflectance pair comprises the reference spectra or the reference spectral signature.
wavelength = lib.Wavelength;
reflectance = lib.Reflectance;
%%Plot the reference spectra read from the ECOSTRESS library.
plot(wavelength,reflectance,'LineWidth',2)
axis tight
xlabel('Wavelength (\mum)')
ylabel('Reflectance (%)')
title('Reference Spectra')
%%Perform Spectral Matching
%%Find the spectral similarity between the reference spectra and the data cube by using the spectralMatch function.
%% By default, the function uses the spectral angle mapper (SAM) method 
scoreMap = spectralMatch(lib,hcube);
%%the score map is a matrix of spatial dimension same as that of the test data
figure('Position',[0 0 500 600])
imagesc(scoreMap)
colormap parula
colorbar
title('Score Map')
%%Classify and Detect Target
figure
imhist(scoreMap);
title('Histogram Plot of Score Map');
xlabel('Score Map Values')
ylabel('Number of occurrences');
%%From the histogram plot, you can infer the minimum score value with prominant number of occurrence as approximately 0.2
maxthreshold = 0.20;
%%Perform thresholding to detect the target region with maximum spectral similarity. Overlay the thresholded image on the RGB image of the hyperspectral data.

thresholdedImg = scoreMap <= maxthreshold;
overlaidImg = imoverlay(rgbImg,thresholdedImg,'green');
%%Display the results
fig = figure('Position',[0 0 900 500]);
axes1 = axes('Parent',fig,'Position',[0.04 0.11 0.4 0.82]);
imagesc(thresholdedImg,'Parent',axes1);
colormap([0 0 0;1 1 1]);
title('Detected Target Region')
axis off
axes2 = axes('Parent',fig,'Position',[0.47 0.11 0.4 0.82]);
imagesc(overlaidImg,'Parent',axes2)
axis off
title('Overlaid Detection Results')