function display_3D_volume_GUI_three_volumes(volume_1, volume_2, volume_3, colormapName, colormapLimits)
    % Get the screen size
    screenSize = get(groot, 'ScreenSize');
    
    % Create the main figure
    fig = figure('Position', screenSize, 'Name', '3D Plane Display GUI');
    
    % Create axes for displaying the planes
    axXY = axes('Parent', fig, 'Position', [0, 0.4, 0.45, 0.45]);
    axXZ = axes('Parent', fig, 'Position', [0.3, 0.4, 0.45, 0.45]);
    axYZ = axes('Parent', fig, 'Position', [0.6, 0.4, 0.45, 0.45]);

    % Initialize the initial planes to display
    currentPlaneXY = 1;
    currentPlaneXZ = 1;
    currentPlaneYZ = 1;
    
    % Display the initial planes using imagesc with transposed data
    planeImageXY = imagesc(axXY, squeeze(volume_1(:,:,currentPlaneXY))');
    colormap(axXY, colormapName); % Specify colormap
    colorbar(axXY);
    caxis(axXY, colormapLimits); % Set colormap limits
    axis(axXY, 'equal', 'tight');
    
    planeImageXZ = imagesc(axXZ, squeeze(volume_2(:, currentPlaneXZ, :))');
    colormap(axXZ, colormapName); % Specify colormap
    colorbar(axXZ);
    caxis(axXZ, colormapLimits); % Set colormap limits
    axis(axXZ, 'equal', 'tight');
       
    planeImageYZ = imagesc(axYZ, squeeze(volume_3(currentPlaneYZ, :, :))');
    colormap(axYZ, colormapName); % Specify colormap
    colorbar(axYZ);
    caxis(axYZ, colormapLimits); % Set colormap limits
    axis(axYZ, 'equal', 'tight');
               
    % Set the axis labels
    xlabel(axXY, 'X');
    ylabel(axXY, 'Y');
    title(axXY, sprintf('Z index: %d/%d', currentPlaneXY, size(volume_1, 3)));

    xlabel(axXZ, 'X');
    ylabel(axXZ, 'Z');
    title(axXZ, sprintf('Y index: %d/%d', currentPlaneXZ, size(volume_2, 2)));

    xlabel(axYZ, 'Y');
    ylabel(axYZ, 'Z');
    title(axYZ, sprintf('X index: %d/%d', currentPlaneYZ, size(volume_3, 1)));
           
    % Create sliders
    sliderXY = uicontrol('Style', 'slider', 'Position', [175 300 750 20],...
        'Min', 1, 'Max', size(volume_1, 3), 'Value', 1, 'SliderStep', [1, 1] / (size(volume_1, 3) - 1), 'Callback', @sliderCallbackXY);
    
    sliderXZ = uicontrol('Style', 'slider', 'Position', [950 300 750 20],...
        'Min', 1, 'Max', size(volume_2, 2), 'Value', 1, 'SliderStep', [1, 1] / (size(volume_2, 2) - 1), 'Callback', @sliderCallbackXZ);  

    sliderXZ = uicontrol('Style', 'slider', 'Position', [1725 300 750 20],...
        'Min', 1, 'Max', size(volume_3, 1), 'Value', 1, 'SliderStep', [1, 1] / (size(volume_3, 2) - 1), 'Callback', @sliderCallbackYZ);  
            
    % Display the current indices on the sliders
    sliderLabelXY = uicontrol('Style', 'text', 'Position', [175, 350, 80, 20], 'String', 'Z index');
    sliderLabelXZ = uicontrol('Style', 'text', 'Position', [950, 350, 80, 20], 'String', 'Y index');
    sliderLabelYZ = uicontrol('Style', 'text', 'Position', [1725, 350, 80, 20], 'String', 'X index');
    
    % Initialize red lines
    lineXZ = [];
    lineYZ = []; 
    lineXY_y = [];
    lineXY_x = [];
    lineXZ_y = [];
    lineYZ_x = [];
    
    % Callback function for the XY plane slider
    function sliderCallbackXY(source, event)
        % Get the slider value
        currentPlaneXY = round(get(source, 'Value'));

        % Update the displayed plane using imagesc with transposed data
        set(planeImageXY, 'CData', squeeze(volume_1(:,:,currentPlaneXY))');
        title(axXY, sprintf('Z index: %d/%d', currentPlaneXY, size(volume_1, 3)));

        % Update the red line indicating the current z location
        zPos = currentPlaneXY;
        
        if ishandle(lineXZ)
            delete(lineXZ);
        end
        
        if ishandle(lineYZ)
            delete(lineYZ);
        end
        
        lineXZ = line(axXZ, [1, size(volume_1, 1)], [zPos, zPos], 'Color', 'red', 'LineWidth', 2);
        lineYZ = line(axYZ, [1, size(volume_3, 1)], [zPos, zPos], 'Color', 'red', 'LineWidth', 2);

        % Update the slider label
        set(sliderLabelXY, 'String', sprintf('Z index %d', currentPlaneXY));
    end

    % Callback function for the XZ plane slider
    function sliderCallbackXZ(source, event)
        % Get the slider value
        currentPlaneXZ = round(get(source, 'Value'));

        % Update the displayed plane using imagesc with transposed data
        set(planeImageXZ, 'CData', squeeze(volume_2(:, currentPlaneXZ, :))');
        title(axXZ, sprintf('Y index: %d/%d', currentPlaneXZ, size(volume_2, 2)));

        % Update the red line indicating the current y location
        yPos = currentPlaneXZ;
        xPos = currentPlaneYZ;
        
        if ishandle(lineXY_y)
            delete(lineXY_y);
        end
        
        if ishandle(lineXZ_y)
            delete(lineXZ_y);
        end
        
        lineXY_y = line(axXY, [1, size(volume_2, 3)], [yPos, yPos], 'Color', 'red', 'LineWidth', 2);
        lineXZ_y = line(axXZ, [xPos, xPos], [1, size(volume_2, 3)], 'Color', 'red', 'LineWidth', 2);

        % Update the slider label
        set(sliderLabelXZ, 'String', sprintf('Y index %d', currentPlaneXZ));
    end

    % Callback function for the YZ plane slider
    function sliderCallbackYZ(source, event)
        % Get the slider value
        currentPlaneYZ = round(get(source, 'Value'));

        % Update the displayed plane using imagesc with transposed data
        set(planeImageYZ, 'CData', squeeze(volume_3(currentPlaneYZ, :, :))');
        title(axYZ, sprintf('X index: %d/%d', currentPlaneYZ, size(volume_3, 1)));

        % Update the red line indicating the current y location
        xPos = currentPlaneYZ;
        yPos = currentPlaneXZ;
        
        if ishandle(lineXY_x)
            delete(lineXY_x);
        end
        
        if ishandle(lineYZ_x)
            delete(lineYZ_x);
        end
                
        lineXY_x = line(axXY, [xPos, xPos], [1, size(volume_3, 1)], 'Color', 'red', 'LineWidth', 2);
        lineYZ_x = line(axYZ, [yPos, yPos], [1, size(volume_2, 3)], 'Color', 'red', 'LineWidth', 2);
        
        % Update the slider label
        set(sliderLabelYZ, 'String', sprintf('X index %d', currentPlaneYZ));
    end

end
