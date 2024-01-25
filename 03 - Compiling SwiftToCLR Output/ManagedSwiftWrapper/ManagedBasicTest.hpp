// This is an auto-generated file. Do not modify.

#pragma once
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <UnmanagedBasicTest.hpp>

namespace ManagedBasicTest {

    ref class APIStruct;
    ref class WorkType;
    ref class APIClass;
    ref class APIEnum;

    public ref class APIStruct {
    private:
    internal:
        UnmanagedBasicTest::APIStruct* wrappedObj;
        APIStruct(UnmanagedBasicTest::APIStruct* objectToTakeOwnershipOf);
    public:
        APIStruct(ManagedBasicTest::APIEnum^ enumValue);
        ~APIStruct();

        ManagedBasicTest::APIEnum^ getEnumValue();
    };

    public ref class WorkType {
    private:
    internal:
        UnmanagedBasicTest::WorkType* wrappedObj;
        WorkType(UnmanagedBasicTest::WorkType* objectToTakeOwnershipOf);
    public:
        ~WorkType();

        static ManagedBasicTest::WorkType^ initWithRawValue(int rawValue);
        static ManagedBasicTest::WorkType^ returnValue();
        static ManagedBasicTest::WorkType^ returnNil();
        static bool operator==(ManagedBasicTest::WorkType^ lhs, ManagedBasicTest::WorkType^ rhs);

        bool isReturnValue();
        bool isReturnNil();
        int getRawValue();
    };

    public ref class APIClass {
    private:
    internal:
        UnmanagedBasicTest::APIClass* wrappedObj;
        APIClass(UnmanagedBasicTest::APIClass* objectToTakeOwnershipOf);
    public:
        APIClass();
        ~APIClass();

        System::String^ getText();
        System::String^ sayHello(System::String^ name);
        ManagedBasicTest::APIStruct^ doWork(ManagedBasicTest::APIStruct^ structValue);
        System::String^ doOptionalWork(ManagedBasicTest::WorkType^ type, System::String^ optionalString);
    };

    public ref class APIEnum {
    private:
    internal:
        UnmanagedBasicTest::APIEnum* wrappedObj;
        APIEnum(UnmanagedBasicTest::APIEnum* objectToTakeOwnershipOf);
    public:
        ~APIEnum();

        static ManagedBasicTest::APIEnum^ initWithRawValue(int rawValue);
        static ManagedBasicTest::APIEnum^ caseOne();
        static ManagedBasicTest::APIEnum^ caseTwo();
        static bool operator==(ManagedBasicTest::APIEnum^ lhs, ManagedBasicTest::APIEnum^ rhs);

        bool isCaseOne();
        bool isCaseTwo();
        int getRawValue();
    };
}
