//
//  VisonCameraMicronPlugin.m
//  VisonCameraMicronPlugin
//
//

#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/Frame.h>
#import <MLKit.h>


@interface VisionCameraMicronPluginObjC : NSObject

+ (MLKImageLabeler*) labeler;

@end

@implementation VisionCameraMicronPluginObjC

+ (MLKImageLabeler*) labeler {
  static MLKImageLabeler* imageLabeler = nil;
  if (imageLabeler == nil) {  
    MLKLocalModel *localModel = [[MLKLocalModel alloc] initWithPath:localModelFilePath]; // Need to add local model file path here!
    MLKCustomImageLabelerOptions *options = [[MLKCustomImageLabelerOptions alloc] initWithLocalModel:localModel];
    options.confidenceThreshold = @(0.0);
    imageLabeler = [MLKImageLabeler imageLabelerWithOptions:options];
  }
  return imageLabeler;
}

static inline id autoStart(Frame* frame, NSArray* arguments) {
  MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:frame.buffer];
  image.orientation = frame.orientation; // <-- TODO: is mirrored?

  NSError* error;
  NSArray<MLKImageLabel*>* labels = [[VisionCameraMicronPluginObjC labeler] resultsInImage:image error:&error];

  NSMutableArray* results = [NSMutableArray arrayWithCapacity:labels.count];
  for (MLKImageLabel* label in labels) {
    [results addObject:@{
      @"label": label.text,
      @"confidence": [NSNumber numberWithFloat:label.confidence]
    }];
  }

  return results;
}

VISION_EXPORT_FRAME_PROCESSOR(autoStart)

@end
