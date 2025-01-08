function averagedArray = slidingWindowAverage_y(inputArray, windowSize)
    % inputArray: 3D array
    % windowSize: integer value representing the sliding window size in depth

    % Get the size of the input array
    [rows, cols, depth] = size(inputArray);

    % Initialize the output array
    averagedArray = zeros(rows, cols, depth);

    % Loop through each column y and calculate the average using the sliding window
    for c = 1:cols
        startC = max(1, c - floor(windowSize/2));
        endC = min(cols, c + floor(windowSize/2));
        averagedArray(:,c,:) = mean(inputArray(:,startC:endC,:), 2);
    end
end