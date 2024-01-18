//
//  SwiftWrapper.cpp
//  SwiftConsumer
//
//  Created by Daniel Kennett (Cascable) on 2024-01-17.
//

#include "SwiftWrapper.hpp"
#include <BasicTest-Swift.h>

// UnmanagedSwiftWrapper::APIStruct Implementation

UnmanagedSwiftWrapper::APIStruct::APIStruct(UnmanagedSwiftWrapper::APIEnum enumValue) {
    BasicTest::APIEnum *arg0 = enumValue.internal.get();
    BasicTest::APIStruct value = BasicTest::APIStruct::init(*arg0);
    internal = std::make_shared<BasicTest::APIStruct>(value);
}

UnmanagedSwiftWrapper::APIStruct::APIStruct(std::shared_ptr<BasicTest::APIStruct> wrapped) {
    internal = wrapped;
}

UnmanagedSwiftWrapper::APIStruct::~APIStruct() {}

UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIStruct::getEnumValue() {
    BasicTest::APIEnum result = internal->getEnumValue();
    return APIEnum(std::make_shared<BasicTest::APIEnum>(result));
}

// UnmanagedSwiftWrapper::APIEnum Implementation

bool UnmanagedSwiftWrapper::APIEnum::isCaseOne() {
    return internal->isCaseOne();
}

bool UnmanagedSwiftWrapper::APIEnum::isCaseTwo() {
    return internal->isCaseTwo();
}

int UnmanagedSwiftWrapper::APIEnum::getRawValue() {
    swift::Int val = internal->getRawValue();
    return (int)val;
}

UnmanagedSwiftWrapper::APIEnum::APIEnum(std::shared_ptr<BasicTest::APIEnum> wrapped) {
    internal = wrapped;
}

UnmanagedSwiftWrapper::APIEnum::~APIEnum() {}

bool UnmanagedSwiftWrapper::APIEnum::operator==(const UnmanagedSwiftWrapper::APIEnum &other) const {
    return (*internal.get() == *other.internal.get());
}

UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIEnum::caseOne() {
    BasicTest::APIEnum val = BasicTest::APIEnum::caseOne();
    return APIEnum(std::make_shared<BasicTest::APIEnum>(val));
}

UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIEnum::caseTwo() {
    BasicTest::APIEnum val = BasicTest::APIEnum::caseTwo();
    return APIEnum(std::make_shared<BasicTest::APIEnum>(val));
}

// UnmanagedSwiftWrapper::APIClass Implementation

UnmanagedSwiftWrapper::APIClass::APIClass() {
    BasicTest::APIClass instance = BasicTest::APIClass::init();
    internal = std::make_shared<BasicTest::APIClass>(instance);
}

UnmanagedSwiftWrapper::APIClass::APIClass(std::shared_ptr<BasicTest::APIClass> wrapped) {
    internal = wrapped;
}

UnmanagedSwiftWrapper::APIClass::~APIClass() {}

std::string UnmanagedSwiftWrapper::APIClass::getText() {
    swift::String result = internal->getText();
    return (std::string)result;
}

std::string UnmanagedSwiftWrapper::APIClass::sayHello(const std::string & name) {
    swift::String arg0 = (swift::String)name;
    swift::String result = internal->sayHello(arg0);
    return (std::string)result;
}

UnmanagedSwiftWrapper::APIStruct UnmanagedSwiftWrapper::APIClass::doWork(APIStruct structValue) {
    BasicTest::APIStruct arg0 = *structValue.internal;
    BasicTest::APIStruct result = internal->doWork(arg0);
    return APIStruct(std::make_shared<BasicTest::APIStruct>(result));
}

