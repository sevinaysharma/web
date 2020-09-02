---
title: LivePhoto
date: 2020-08-11 10:01:22
tags:
 - LivePhoto
categories:
 - iOS
 - 音视频
---

## 产品体验

1. 关于声音。LivePhoto 本身会记录声音。在相册查看时可以播放声音，在设置为动态壁纸时系统不会播放声音，此时只有画面
2. 主屏幕设定 LivePhoto 后只会显示 LivePhoto 中的静态图片
3. 手指结束按压后，视频停止播放，同时从当前视频帧的内容过度到 LivePhoto 中的静态图片

## 数据存储

LivePhoto 支持两种存储形式。默认使用容器格式 `HEIC`。容器中存储的是多张图片和对应的声音文件。另一种是兼容格式，将 LivePhoto 拆分为 `JPG` 文件和 `MOV` 视频文件。

***本文中实现 LivePhoto 效果是基于兼容格式实现***。


## 原理及实现

LivePhoto 使用 Identifier（一般用 UUID）将图片和视频 *pair* 起来。所以制作 LivePhoto 需要做三件事：

1. 在图片和视频中添加 Identifier 元数据
2. 在视频文件中添加一个数据轨，该数据流用来描述播放静态图片的时间段
3. 使用 `PhPhotoLibrary` 将数据保存到相册（或者生成 `PHLivePhoto` 用于展示）

具体实现可以参照 [LivePhotoDemo](https://github.com/genadyo/LivePhotoDemo)。文末也会附相关代码。

这里需要注意的是，生成 LivePhoto 预览数据 `PHLivePhoto` 时传入的参数是资源 URL。如果使用的视频和壁纸在服务器上，最好先将资源下载到本地，否则会导致预览无效果。

### 坑

需要注意的是，在使用 `+ (PHLivePhotoRequestID)requestLivePhotoWithResourceFileURLs:(NSArray<NSURL *> *)fileURLs placeholderImage:(nullable UIImage *)image targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode resultHandler:(void(^)(PHLivePhoto *_Nullable livePhoto, NSDictionary *info))resultHandler` 生成 `PHLivePhoto` 时 *fileURLs* 中的 fileUrl 需要带上拓展名，不然会失败。

## FFmpeg

刚开始尝试过使用 FFmpeg 来处理视频。简单添加 metadata 没有问题，但是如何添加 `Data: none (mebx / 0x7862656D), 1 kb/s (default)` 轨还没有找到合适的方法。

```
+ (void)writeToFileWithOriginJPGPath:(NSURL *)originJPGPath targetWriteFilePath:(NSURL *)finalJPGPath assetIdentifier:(NSString *)assetIdentifier {
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)finalJPGPath, kUTTypeJPEG, 1, nil);
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)[NSData dataWithContentsOfFile:originJPGPath.path], nil);
    NSMutableDictionary *metaData = [(__bridge_transfer  NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) mutableCopy];
    
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setValue:assetIdentifier forKey:kFigAppleMakerNote_AssetIdentifier];
    [metaData setValue:makerNote forKey:(__bridge_transfer  NSString*)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(dest, imageSourceRef, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
}
```

```
+ (void)writeToFileWithOriginMovPath:(NSURL *)originMovPath targetWriteFilePath:(NSURL *)finalMovPath assetIdentifier:(NSString *)assetIdentifier {
    
    AVURLAsset* asset = [AVURLAsset assetWithURL:originMovPath];
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    if (!videoTrack) {
        return;
    }

    if (!audioTrack) {
        return;
    }
    
    AVAssetReaderOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];

    NSDictionary *audioDic = @{AVFormatIDKey :@(kAudioFormatLinearPCM),
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVLinearPCMBitDepthKey :@(16)
                               };
    
    AVAssetReaderTrackOutput *audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioDic];
    NSError *error;
    
    
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if([reader canAddOutput:videoOutput]) {
        [reader addOutput:videoOutput];
    } else {
        NSLog(@"Add video output error\n");
    }
    
    if([reader canAddOutput:audioOutput]) {
        [reader addOutput:audioOutput];
    } else {
        NSLog(@"Add audio output error\n");
    }

    
    NSDictionary * outputSetting = @{AVVideoCodecKey: AVVideoCodecH264,
                                     AVVideoWidthKey: [NSNumber numberWithFloat:videoTrack.naturalSize.width],
                                     AVVideoHeightKey: [NSNumber numberWithFloat:videoTrack.naturalSize.height]
                                     };
    
    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSetting];
    videoInput.expectsMediaDataInRealTime = true;
    videoInput.transform = videoTrack.preferredTransform;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [ NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   [ NSNumber numberWithFloat: 44100], AVSampleRateKey,
                                   [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                                   nil];
    
    AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[audioTrack mediaType] outputSettings:audioSettings];
    audioInput.expectsMediaDataInRealTime = true;
    audioInput.transform = audioTrack.preferredTransform;
    
    NSError *error_two;
    
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:finalMovPath fileType:AVFileTypeQuickTimeMovie error:&error_two];
    if(error_two) {
        NSLog(@"CreateWriterError:%@\n",error_two);
    }
    writer.metadata = @[ [self metaDataSet:assetIdentifier]];
    [writer addInput:videoInput];
    [writer addInput:audioInput];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                                           kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    AVAssetWriterInputMetadataAdaptor *adapter = [self metadataSetAdapter];
    [writer addInput:adapter.assetWriterInput];
    [writer startWriting];
    [reader startReading];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    
    CMTimeRange dummyTimeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000));
    //Meta data reset:
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyStillImageTime;
    item.keySpace = kKeySpaceQuickTimeMetadata;
    item.value = [NSNumber numberWithInt:0];
    item.dataType = @"com.apple.metadata.datatype.int8";
    [adapter appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc] initWithItems:[NSArray arrayWithObject:item] timeRange:dummyTimeRange]];
    
    
    dispatch_queue_t createMovQueue = dispatch_queue_create("createMovQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(createMovQueue, ^{
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef videoBuffer = [videoOutput copyNextSampleBuffer];
            CMSampleBufferRef audioBuffer = [audioOutput copyNextSampleBuffer];
            if (videoBuffer) {
                while (!videoInput.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData) {
                    usleep(1);
                }
                if (audioBuffer) {
                    [audioInput appendSampleBuffer:audioBuffer];
                    CFRelease(audioBuffer);
                }
                
                //不剪切：
                [adaptor.assetWriterInput appendSampleBuffer:videoBuffer];
                CMSampleBufferInvalidate(videoBuffer);
                CFRelease(videoBuffer);
                videoBuffer = nil;

            } else {
                continue;
            }
            // NULL?
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [writer finishWritingWithCompletionHandler:^{
                NSLog(@"Finish \n");
                dispatch_semaphore_signal(semaphore);
            }];
        });
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
```