function averagedArray = slidingWindowAverage_x(inputArray, windowSize)
    % inputArray: 3D array
    % windowSize: integer value representing the sliding window size in depth

    % Get the size of the input array
    [rows, cols, depth] = size(inputArray);

    % Initialize the output array
    averagedArray = zeros(rows, cols, depth);

    % Loop through each column y and calculate the average using the sliding window
    for r = 1:rows
        startR = max(1, r - floor(windowSize/2));
        endR = min(rows, r + floor(windowSize/2));
        averagedArray(r,:,:) = mean(inputArray(startR:endR,:,:), 1);
    end
end