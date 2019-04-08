function [topN] = selectTopN(I,n,db)
[radX, radY] = radonTrans(I);
    %Construct the array of topn 
    %Construct with first 5 values in db so that sorting function will work
    topN(n) = struct('name','','X',[],'Y',[]);
    for j=n:-1:1
        bhC = bhattacharyyaCoef(db(j), radX, radY);
        topN(j).X = db(j).X;
        topN(j).Y = db(j).Y;
        topN(j).name = db(j).name;
        topN(j).bhC = bhC;
    end
    %Sort the first n values put into the array
    [~,idxArr] = sort(arrayfun(@(x) x.bhC, topN));
    topN = topN(idxArr);
    % Iterate through db and find the best matching images
    for i = n+1:length(db)
        bhC = bhattacharyyaCoef(db(i), radX, radY);
        minTopN = min([topN.bhC]);
        if bhC > minTopN
            %place the new struct into the left most position of the array
            %create bhC field which contains the bhattacaryya coeffecient
            topN(1).X = db(i).X;
            topN(1).Y = db(i).Y;
            topN(1).name = db(i).name;
            topN(1).bhC = bhC;
            %create index array of properly sorted function
            [~,idxArr] = sort(arrayfun(@(x) x.bhC, topN));
            %sort topN array
            topN = topN(idxArr);
        end
    end
end

