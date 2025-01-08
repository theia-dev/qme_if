function mask_xyz = create_3D_mask_from_cross_sections(array1_yx, array2_zx, array3_zy)

% Replicate cross-sections along remaining orthogonal plane
array1_yxz = repmat(array1_yx, [1 1 size(array2_zx,1)]);
array2_zxy = repmat(array2_zx, [1 1 size(array1_yx,1)]);
array3_zyx = repmat(array3_zy, [1 1 size(array2_zx,2)]);

% Rearrange arrays so that they have equivalent dimensions
array1_xyz = permute(array1_yxz, [2 1 3]);
array2_xyz = permute(array2_zxy, [2 3 1]);
array3_xyz = permute(array3_zyx, [3 2 1]);

% Create 3-D mask
mask_xyz = array1_xyz.*array2_xyz.*array3_xyz;

end
