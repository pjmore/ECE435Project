function [I] = OTS(imgName)
imgName = convertStringsToChars(imgName);
gamma = readConf('gamma');
warning('off','images:initSize:adjustingMag');
fin = fopen(imgName, 'r', 'b','US-ASCII');
c = onCleanup(@()fclose(fin));
I = fread(fin, [2048,2048], 'uint16=>uint16','b')';
I = uint16(4095) - uint16(I);
temp = double(I).^gamma;
temp = temp * (2^16 -1)/max(temp,[],'all');
I = uint16(temp);
warning('on','images:initSize:adjustingMag');
name = strcat(imgName(1:length(imgName)- 3), 'tif');
slashes =  strfind(name,'\');
outFile = strcat(readConf('baseDir'),'db\Pictures\Post\',name(slashes(end)+1:end));
imwrite(I, outFile);
end



