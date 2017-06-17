
# TZImagePickerController学习

```
获取原图
- (void)pushTZImagePickerController {
    __weak typeof(self)weakSelf = self;
    [self.tz_imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        // 保存图片，获取到asset
        _selectedPhotos = [NSMutableArray arrayWithArray:photos];
        _selectedAssets = [NSMutableArray arrayWithArray:assets];
        [weakSelf.photoCollectionView reloadData];
//        //获取原图
//        for (id asset in assets) {
//            [[TZImageManager manager] getOriginalPhotoWithAsset: asset completion:^(UIImage *photo, NSDictionary *info) {
//                DBLOG(@"原图 photo = %@ info = %@",photo, info);
//            }];
//        }
        // 打印图片信息
        if (iOS8Later) {
            for (PHAsset *phAsset in assets) {
                DBLOG(@"所选图片 pixelWidth = %zd pixelHeight:%zd",phAsset.pixelWidth, phAsset.pixelHeight);
            }
        }
    }];
    [self presentViewController:self.tz_imagePickerVc animated:YES completion:nil];
}

```


Demo中这个是为啥？

```
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if (self.allowCropSwitch.isOn) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = self.needCircleCropSwitch.isOn;
                            imagePicker.circleCropRadius = 100;
                            [self presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
```

