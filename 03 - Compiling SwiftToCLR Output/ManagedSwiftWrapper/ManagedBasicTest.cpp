// This is an auto-generated file. Do not modify.

#include "ManagedBasicTest.hpp"
#include <msclr/marshal_cppstd.h>

using namespace msclr::interop;

// Implementation of ManagedBasicTest::APIStruct

ManagedBasicTest::APIStruct::APIStruct(UnmanagedBasicTest::APIStruct* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedBasicTest::APIStruct::APIStruct(ManagedBasicTest::APIEnum^ enumValue) {
    UnmanagedBasicTest::APIEnum arg0 = *enumValue->wrappedObj;
    UnmanagedBasicTest::APIStruct* newObject = new UnmanagedBasicTest::APIStruct(arg0);
    wrappedObj = newObject;
}

ManagedBasicTest::APIStruct::~APIStruct() {
    delete wrappedObj;
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIStruct::getEnumValue() {
    UnmanagedBasicTest::APIEnum unmanagedResult = wrappedObj->getEnumValue();
    return gcnew ManagedBasicTest::APIEnum(new UnmanagedBasicTest::APIEnum(unmanagedResult));
}

// Implementation of ManagedBasicTest::WorkType

ManagedBasicTest::WorkType::WorkType(UnmanagedBasicTest::WorkType* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedBasicTest::WorkType::~WorkType() {
    delete wrappedObj;
}

ManagedBasicTest::WorkType^ ManagedBasicTest::WorkType::initWithRawValue(int rawValue) {
    int arg0 = rawValue;
    std::optional<UnmanagedBasicTest::WorkType> unmanagedResult = UnmanagedBasicTest::WorkType::initWithRawValue(arg0);
    return (unmanagedResult.has_value() ? gcnew ManagedBasicTest::WorkType(new UnmanagedBasicTest::WorkType(unmanagedResult.value())) : nullptr);
}

ManagedBasicTest::WorkType^ ManagedBasicTest::WorkType::returnValue() {
    UnmanagedBasicTest::WorkType unmanagedResult = UnmanagedBasicTest::WorkType::returnValue();
    return gcnew ManagedBasicTest::WorkType(new UnmanagedBasicTest::WorkType(unmanagedResult));
}

ManagedBasicTest::WorkType^ ManagedBasicTest::WorkType::returnNil() {
    UnmanagedBasicTest::WorkType unmanagedResult = UnmanagedBasicTest::WorkType::returnNil();
    return gcnew ManagedBasicTest::WorkType(new UnmanagedBasicTest::WorkType(unmanagedResult));
}

bool ManagedBasicTest::WorkType::operator==(ManagedBasicTest::WorkType^ lhs, ManagedBasicTest::WorkType^ rhs) {
    if (Object::ReferenceEquals(lhs, nullptr) && Object::ReferenceEquals(rhs, nullptr)) { return true; }
    if (Object::ReferenceEquals(lhs, nullptr) || Object::ReferenceEquals(rhs, nullptr)) { return false; }
    return (*lhs->wrappedObj == *rhs->wrappedObj);
}

bool ManagedBasicTest::WorkType::isReturnValue() {
    bool unmanagedResult = wrappedObj->isReturnValue();
    return unmanagedResult;
}

bool ManagedBasicTest::WorkType::isReturnNil() {
    bool unmanagedResult = wrappedObj->isReturnNil();
    return unmanagedResult;
}

int ManagedBasicTest::WorkType::getRawValue() {
    int unmanagedResult = wrappedObj->getRawValue();
    return unmanagedResult;
}

// Implementation of ManagedBasicTest::APIClass

ManagedBasicTest::APIClass::APIClass(UnmanagedBasicTest::APIClass* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedBasicTest::APIClass::APIClass() {
    UnmanagedBasicTest::APIClass* newObject = new UnmanagedBasicTest::APIClass();
    wrappedObj = newObject;
}

ManagedBasicTest::APIClass::~APIClass() {
    delete wrappedObj;
}

System::String^ ManagedBasicTest::APIClass::getText() {
    std::string unmanagedResult = wrappedObj->getText();
    return marshal_as<System::String^>(unmanagedResult);
}

System::String^ ManagedBasicTest::APIClass::sayHello(System::String^ name) {
    const std::string& arg0 = marshal_as<std::string>(name);
    std::string unmanagedResult = wrappedObj->sayHello(arg0);
    return marshal_as<System::String^>(unmanagedResult);
}

ManagedBasicTest::APIStruct^ ManagedBasicTest::APIClass::doWork(ManagedBasicTest::APIStruct^ structValue) {
    UnmanagedBasicTest::APIStruct arg0 = *structValue->wrappedObj;
    UnmanagedBasicTest::APIStruct unmanagedResult = wrappedObj->doWork(arg0);
    return gcnew ManagedBasicTest::APIStruct(new UnmanagedBasicTest::APIStruct(unmanagedResult));
}

System::String^ ManagedBasicTest::APIClass::doOptionalWork(ManagedBasicTest::WorkType^ type, System::String^ optionalString) {
    UnmanagedBasicTest::WorkType arg0 = *type->wrappedObj;
    std::optional<std::string> arg1 = (optionalString == nullptr ? std::nullopt : std::optional<std::string>(marshal_as<std::string>(optionalString)));
    std::optional<std::string> unmanagedResult = wrappedObj->doOptionalWork(arg0, arg1);
    return (unmanagedResult.has_value() ? marshal_as<System::String^>(unmanagedResult.value()) : nullptr);
}

// Implementation of ManagedBasicTest::APIEnum

ManagedBasicTest::APIEnum::APIEnum(UnmanagedBasicTest::APIEnum* objectToTakeOwnershipOf) {
    wrappedObj = objectToTakeOwnershipOf;
}

ManagedBasicTest::APIEnum::~APIEnum() {
    delete wrappedObj;
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIEnum::initWithRawValue(int rawValue) {
    int arg0 = rawValue;
    std::optional<UnmanagedBasicTest::APIEnum> unmanagedResult = UnmanagedBasicTest::APIEnum::initWithRawValue(arg0);
    return (unmanagedResult.has_value() ? gcnew ManagedBasicTest::APIEnum(new UnmanagedBasicTest::APIEnum(unmanagedResult.value())) : nullptr);
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIEnum::caseOne() {
    UnmanagedBasicTest::APIEnum unmanagedResult = UnmanagedBasicTest::APIEnum::caseOne();
    return gcnew ManagedBasicTest::APIEnum(new UnmanagedBasicTest::APIEnum(unmanagedResult));
}

ManagedBasicTest::APIEnum^ ManagedBasicTest::APIEnum::caseTwo() {
    UnmanagedBasicTest::APIEnum unmanagedResult = UnmanagedBasicTest::APIEnum::caseTwo();
    return gcnew ManagedBasicTest::APIEnum(new UnmanagedBasicTest::APIEnum(unmanagedResult));
}

bool ManagedBasicTest::APIEnum::operator==(ManagedBasicTest::APIEnum^ lhs, ManagedBasicTest::APIEnum^ rhs) {
    if (Object::ReferenceEquals(lhs, nullptr) && Object::ReferenceEquals(rhs, nullptr)) { return true; }
    if (Object::ReferenceEquals(lhs, nullptr) || Object::ReferenceEquals(rhs, nullptr)) { return false; }
    return (*lhs->wrappedObj == *rhs->wrappedObj);
}

bool ManagedBasicTest::APIEnum::isCaseOne() {
    bool unmanagedResult = wrappedObj->isCaseOne();
    return unmanagedResult;
}

bool ManagedBasicTest::APIEnum::isCaseTwo() {
    bool unmanagedResult = wrappedObj->isCaseTwo();
    return unmanagedResult;
}

int ManagedBasicTest::APIEnum::getRawValue() {
    int unmanagedResult = wrappedObj->getRawValue();
    return unmanagedResult;
}
