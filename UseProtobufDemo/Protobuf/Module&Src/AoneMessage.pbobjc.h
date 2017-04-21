// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: aoneMessage.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AoneMessageRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface AoneMessageRoot : GPBRootObject
@end

#pragma mark - Test_Req

typedef GPB_ENUM(Test_Req_FieldNumber) {
  Test_Req_FieldNumber_Param1 = 1,
  Test_Req_FieldNumber_Param2 = 2,
};

@interface Test_Req : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *param1;

@property(nonatomic, readwrite) int32_t param2;

@end

#pragma mark - Test_Rsp

typedef GPB_ENUM(Test_Rsp_FieldNumber) {
  Test_Rsp_FieldNumber_Result1 = 1,
  Test_Rsp_FieldNumber_Result2 = 2,
};

@interface Test_Rsp : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *result1;

@property(nonatomic, readwrite) int64_t result2;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
