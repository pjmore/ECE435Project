old = cd('left lung');
left = dir("*.gif");
cd(old);
old = cd('right lung');
right = dir("*.gif");
cd(old)

for i = 1:length(left)
    name = left(i).name;
    k = 1;
    for j =1:length(right)
        if name == right(j).name
            k = j;
            break
        end
    end
    old = cd('left lung');
    left(i).name
    l = imread(left(i).name);
    cd(old);
    old = cd('right lung');
    r = imread(right(k).name);
    cd(old);
    mask = l+r;
    mask(mask > 1) = 1;
    old = cd('C:\Users\patri\Documents\MatlabAssignments\medImgProc\project\compiledProject\db\Masks');
    imwrite(mask,name);
    cd(old);
end
    
