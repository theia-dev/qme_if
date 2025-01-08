function averagedArray = slidingWindowAverage_z(inputArray, windowSize)
    % inputArray: 3D array
    % windowSize: integer value representing the sliding window size in depth

    % Get the size of the input array
    [rows, cols, depth] = size(inputArray);

    % Initialize the output array
    averagedArray = zeros(rows, cols, depth);

    % Loop through each depth position and calculate the average using the sliding window
    for d = 1:depth
        startD = max(1, d - floor(windowSize/2));
        endD = min(depth, d + floor(windowSize/2));
        averagedArray(:,:,d) = mean(inputArray(:,:,startD:endD), 3);
    end
end