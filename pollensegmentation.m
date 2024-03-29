function [out] = pollensegmentation(folder, ccvlist, imdis) 

add = 0;
varTypes = ["string","double","double", "double", "double", "double","double","double","double","double","double",...
    "double","double","double","double","double","double","double","double","double", ...
    "double","double","double","double","double","double","double","double","double", ...
    "double","double","double","double","double","double","double","double","double"];
varNames = ["CCVFileName","Timepoint","CCVMeanp1","CCVMeanp2","CCVMeanp3","CCVMeanp4","CCVMeanp5","CCVMeanp6","CCVMeanp7","CCVMeanp8","CCVMeanp9", ...
    "CCVMedianp1","CCVMedianp2","CCVMedianp3","CCVMedianp4","CCVMedianp5","CCVMedianp6","CCVMedianp7","CCVMedianp8","CCVMedianp9", ...
    "CCVSTDEVp1", "CCVSTDEVp2","CCVSTDEVp3","CCVSTDEVp4","CCVSTDEVp5","CCVSTDEVp6","CCVSTDEVp7","CCVSTDEVp8","CCVSTDEVp9", ...
    "COVp1", "COVp2","COVp3","COVp4","COVp5","COVp6","COVp7","COVp8","COVp9"];
out = table('Size', [length(ccvlist), length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);

for a = 1:length(ccvlist)
    add = add+1
    currentfile = strcat(folder,'\',ccvlist(a));
    currentim = dlmread(currentfile);
    
    if imdis==1
    figure()
    end
    %imshow(currentim)
    
    %axis on
    %clim auto
    %colorbar()
    
    %%create mask
    formask = currentim;
    imbinarize(formask);
    %figure()
    %imshow(formask)
    %axis on

    %segmentation code based off of Image Analyst's Image Segmentation
    %Tutorial - uses connected componenets labeling
    [labeledImage, numgrains] = bwlabel(medfilt2(formask,[3,3]), 8);    %8 used to set connectivity type 
        
    
%{
    %remove blobs smaller than 5 pixels
    for j = 1:length(unique(labeledImage))-1
        %-1 due to zero in labels
        location = find(labeledImage==j);
        length(location);
        if(length(location) < 5)
            labeledImage(location) = 0;
        end
    end

   
    

    %remove boundaries that mark anything smaller than 5 pixels
    editedbounds = [];
    boundidx = 1;
    for i = 1:length(boundaries)
        boundsz = length(boundaries{i});
        if boundsz>5
            editedbounds{boundidx,1} = boundaries{i};
            boundidx = boundidx +1;
        end
    end
%}

     % mainly for visualization and add boundary based filters
    boundaries = bwboundaries(labeledImage, 8,"noholes");

    %coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle');
    %imshow(coloredLabels);

    
    
    if imdis==1
    cm = [0 0 0; jet(12)];
    imagesc(labeledImage);colormap(cm);colorbar();
    numberOfBoundaries = size(boundaries, 1); 
    hold on; 
    for k = 1 : numberOfBoundaries
	    thisBoundary = boundaries{k}; % Get boundary for this specific blob.
	    x = thisBoundary(:,2); % Column 2 is the columns, which is x.
	    y = thisBoundary(:,1); % Column 1 is the rows, which is y.
	    plot(x, y, 'w-', 'LineWidth', 1); % Plot boundary in red.

    end
    end
    
    %separate pollen images
    pollenvalues = {};
    for g = 1:(length(unique(labeledImage))-1)
        
        %area = find(labeledImage~=g);

        lm= labeledImage;
        area = lm==g ;

        %for h = 1:length(area)
        %lm(area(h)) = 0;     %everything not specific to pollen grain is 0
        %end 
        lm(area)  = 1;
        lm(~area) = 0;     %everything above 0 is 1;

        pollenmask = currentim.*lm;

        pollenvalues{g,1} = pollenmask;
    end 

    pollenvalues;
    
    %assign all pollen images to different variables
    p1 = pollenvalues{1,1};
    p2 = pollenvalues{2,1};
    p3 = pollenvalues{3,1};
    p4 = pollenvalues{4,1};
    p5 = pollenvalues{5,1};
    p6 = pollenvalues{6,1};
    p7 = pollenvalues{7,1};
    p8 = pollenvalues{8,1};
    p9 = pollenvalues{9,1};
    p10 = pollenvalues{10,1};
    %p11 = pollenvalues{11,1};
    

    
    
%{ 
%use for "manual" boundary box segmentation
    %need a better way to compute
            % c  r w  h 
    p1coor = [62 1 25 25];
    p2coor = [53 24 30 30];
    p3coor = [108 10 25 25];
    p4coor = [81 78 25 25];
    p5coor = [135 49 25 25];
    p6coor = [25 175 25 25];
    p7coor = [195 148 25 25];
    p8coor = [113 218 25 25];
    p9coor = [202 223 30 30];


    rectangle('Position', p1coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p2coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p3coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p4coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p5coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p6coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p7coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p8coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    rectangle('Position', p9coor, 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-')
    
    p1 = currentim(p1coor(2):p1coor(2)+p1coor(4), p1coor(1):p1coor(1)+p1coor(3));
    p2 = currentim(p2coor(2):p2coor(2)+p2coor(4), p2coor(1):p2coor(1)+p2coor(3));
    p3 = currentim(p3coor(2):p3coor(2)+p3coor(4), p3coor(1):p3coor(1)+p3coor(3));
    p4 = currentim(p4coor(2):p4coor(2)+p4coor(4), p4coor(1):p4coor(1)+p4coor(3));
    p5 = currentim(p5coor(2):p5coor(2)+p5coor(4), p5coor(1):p5coor(1)+p5coor(3));
    p6 = currentim(p6coor(2):p6coor(2)+p6coor(4), p6coor(1):p6coor(1)+p6coor(3));
    p7 = currentim(p7coor(2):p7coor(2)+p7coor(4), p7coor(1):p7coor(1)+p7coor(3));
    p8 = currentim(p8coor(2):p8coor(2)+p8coor(4), p8coor(1):p8coor(1)+p8coor(3));
    p9 = currentim(p9coor(2):p9coor(2)+p9coor(4), p9coor(1):p9coor(1)+p9coor(3));

%}

    %only take the pollen grains that you want and RENAME to 1-9 values
    %current skipping 7 and 11
    ccvalsp1 = nonzeros(p1);
    ccvalsp2 = nonzeros(p2);
    ccvalsp3 = nonzeros(p3);
    ccvalsp4 = nonzeros(p4);
    ccvalsp5 = nonzeros(p5);
    ccvalsp6 = nonzeros(p6);
    ccvalsp7 = nonzeros(p8); %skipped 7
    ccvalsp8 = nonzeros(p9);
    ccvalsp9 = nonzeros(p10); %exclude 11

    %remove outliers in tm values
    ccvalsp1(ccvalsp1 > 8000) = [];
    ccvalsp2(ccvalsp2 > 8000) = [];
    ccvalsp3(ccvalsp3 > 8000) = [];
    ccvalsp4(ccvalsp4 > 8000) = [];
    ccvalsp5(ccvalsp5 > 8000) = [];
    ccvalsp6(ccvalsp6 > 8000) = [];
    ccvalsp7(ccvalsp7 > 8000) = [];
    ccvalsp8(ccvalsp8 > 8000) = [];
    ccvalsp9(ccvalsp9 > 8000) = [];
   
    %calculate statistics for each file type
    meanp1 = mean(ccvalsp1,'all');
    meanp2 = mean(ccvalsp2,'all');
    meanp3 = mean(ccvalsp3,'all');
    meanp4 = mean(ccvalsp4,'all');
    meanp5 = mean(ccvalsp5,'all');
    meanp6 = mean(ccvalsp6,'all');
    meanp7 = mean(ccvalsp7,'all');
    meanp8 = mean(ccvalsp8,'all');
    meanp9 = mean(ccvalsp9,'all');

    medianp1 = median(ccvalsp1,'all');
    medianp2 = median(ccvalsp2,'all');
    medianp3 = median(ccvalsp3,'all');
    medianp4 = median(ccvalsp4,'all');
    medianp5 = median(ccvalsp5,'all');
    medianp6 = median(ccvalsp6,'all');
    medianp7 = median(ccvalsp7,'all');
    medianp8 = median(ccvalsp8,'all');
    medianp9 = median(ccvalsp9,'all');

    sdevp1 = std(ccvalsp1,0, 'all');        % w = 0 to normalize by N-1 (default option)
    sdevp2 = std(ccvalsp2,0, 'all');
    sdevp3 = std(ccvalsp3,0, 'all');
    sdevp4 = std(ccvalsp4,0, 'all');
    sdevp5 = std(ccvalsp5,0, 'all');
    sdevp6 = std(ccvalsp6,0, 'all');
    sdevp7 = std(ccvalsp7,0, 'all');
    sdevp8 = std(ccvalsp8,0, 'all');
    sdevp9 = std(ccvalsp9,0, 'all');

    covp1 = sdevp1/meanp1;
    covp2 = sdevp2/meanp2;
    covp3 = sdevp3/meanp3;
    covp4 = sdevp4/meanp4;
    covp5 = sdevp5/meanp5;
    covp6 = sdevp6/meanp6;
    covp7 = sdevp7/meanp7;
    covp8 = sdevp8/meanp8;
    covp9 = sdevp9/meanp9;

   
    out(a,:) = {ccvlist(a), a, meanp1, meanp2,meanp3,meanp4,meanp5,meanp6,meanp7,meanp8,meanp9, ...
        medianp1, medianp2, medianp3, medianp4, medianp5, medianp6, medianp7, medianp8, medianp9, ...
        sdevp1, sdevp2,sdevp3,sdevp4,sdevp5,sdevp6,sdevp7,sdevp8,sdevp9, ...
        covp1, covp2, covp3, covp4, covp5, covp6, covp7, covp8, covp9};

    if imdis == 2
        subplot(5,2,1)
        imshow(currentim)
        clim auto
        subplot(5,2,2)
        imshow(p1)
        clim auto
        subplot(5,2,3)
        imshow(p2)
        clim auto
        subplot(5,2,4)
        imshow(p3)
        clim auto
        subplot(5,2,5)
        imshow(p4)
        clim auto
        subplot(5,2,6)
        imshow(p5)
        clim auto
        subplot(5,2,7)
        imshow(p6)
        clim auto
        subplot(5,2,8)
        imshow(p7)
        clim auto
        subplot(5,2,9)
        imshow(p8)
        clim auto
        subplot(5,2,10)
        imshow(p9)
        clim auto
    else 
        disp("doyouwantimages = 0, no images displayed")
    end

   
 disp('function used: pollensegmentation')

end

