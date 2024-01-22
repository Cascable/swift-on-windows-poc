// This is an auto-generated file. Do not modify.

#include "UnmanagedBasicTest.hpp"
#include <BasicTest-Swift.h>

// Implementation of UnmanagedBasicTest::APIStruct

UnmanagedBasicTest::APIStruct::APIStruct(std::shared_ptr<BasicTest::APIStruct> swiftObj) {
    this->swiftObj = swiftObj;
}

UnmanagedBasicTest::APIStruct::APIStruct(const UnmanagedBasicTest::APIEnum & enumValue) {
    const BasicTest::APIEnum & arg0 = *enumValue.swiftObj.get();
    BasicTest::APIStruct instance = BasicTest::APIStruct::init(arg0);
    swiftObj = std::make_shared<BasicTest::APIStruct>(instance);
}

UnmanagedBasicTest::APIStruct::~APIStruct() {}

UnmanagedBasicTest::APIEnum UnmanagedBasicTest::APIStruct::getEnumValue() {
    BasicTest::APIEnum swiftResult = swiftObj->getEnumValue();
    return UnmanagedBasicTest::APIEnum(std::make_shared<BasicTest::APIEnum>(swiftResult));
}

// Implementation of UnmanagedBasicTest::APIClass

UnmanagedBasicTest::APIClass::APIClass(std::shared_ptr<BasicTest::APIClass> swiftObj) {
    this->swiftObj = swiftObj;
}

UnmanagedBasicTest::APIClass::APIClass() {
    BasicTest::APIClass instance = BasicTest::APIClass::init();
    swiftObj = std::make_shared<BasicTest::APIClass>(instance);
}

UnmanagedBasicTest::APIClass::~APIClass() {}

std::string UnmanagedBasicTest::APIClass::getText() {
    swift::String swiftResult = swiftObj->getText();
    return (std::string)swiftResult;
}

std::string UnmanagedBasicTest::APIClass::sayHello(const std::string & name) {
    const swift::String & arg0 = (swift::String)name;
    swift::String swiftResult = swiftObj->sayHello(arg0);
    return (std::string)swiftResult;
}

UnmanagedBasicTest::APIStruct UnmanagedBasicTest::APIClass::doWork(const UnmanagedBasicTest::APIStruct & structValue) {
    const BasicTest::APIStruct & arg0 = *structValue.swiftObj.get();
    BasicTest::APIStruct swiftResult = swiftObj->doWork(arg0);
    return UnmanagedBasicTest::APIStruct(std::make_shared<BasicTest::APIStruct>(swiftResult));
}

// Implementation of UnmanagedBasicTest::APIEnum

UnmanagedBasicTest::APIEnum::APIEnum(std::shared_ptr<BasicTest::APIEnum> swiftObj) {
    this->swiftObj = swiftObj;
}

UnmanagedBasicTest::APIEnum::~APIEnum() {}

UnmanagedBasicTest::APIEnum UnmanagedBasicTest::APIEnum::caseOne() {
    BasicTest::APIEnum value = BasicTest::APIEnum::caseOne();
    return UnmanagedBasicTest::APIEnum(std::make_shared<BasicTest::APIEnum>(value));
}

UnmanagedBasicTest::APIEnum UnmanagedBasicTest::APIEnum::caseTwo() {
    BasicTest::APIEnum value = BasicTest::APIEnum::caseTwo();
    return UnmanagedBasicTest::APIEnum(std::make_shared<BasicTest::APIEnum>(value));
}

bool UnmanagedBasicTest::APIEnum::operator==(const UnmanagedBasicTest::APIEnum &other) const {
    return (*swiftObj.get() == *other.swiftObj.get());
}

bool UnmanagedBasicTest::APIEnum::isCaseOne() {
    bool swiftResult = swiftObj->isCaseOne();
    return swiftResult;
}

bool UnmanagedBasicTest::APIEnum::isCaseTwo() {
    bool swiftResult = swiftObj->isCaseTwo();
    return swiftResult;
}

int UnmanagedBasicTest::APIEnum::getRawValue() {
    swift::Int swiftResult = swiftObj->getRawValue();
    return (int)swiftResult;
}

