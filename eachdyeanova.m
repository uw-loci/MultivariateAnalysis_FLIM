function [anovastats, anovatbl] = eachdyeanova(allinfo, dyenumber)

%separate out specific dye inforation
dyedata = allinfo(allinfo.FluorescentDye == dyenumber, :);

%measurement you want to test
affectedvariable = dyedata.CCVMedian;

%get factors that may affect measurements
power = dyedata.PowerCategory;
day = dyedata.Day;
rois = dyedata.ROI;

[anovastats, anovatbl] = anovan(affectedvariable, {power, day, rois});

end 
