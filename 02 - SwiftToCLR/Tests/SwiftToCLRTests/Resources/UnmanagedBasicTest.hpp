// This is an auto-generated file. Do not modify.

#ifndef UnmanagedBasicTest_hpp
#define UnmanagedBasicTest_hpp
#include <memory>
#include <string>

namespace BasicTest {
    class APIStruct;
    class APIClass;
    class APIEnum;
}

namespace UnmanagedBasicTest {

    class APIStruct;
    class APIClass;
    class APIEnum;

    class APIStruct {
    private:
    public:
        std::shared_ptr<BasicTest::APIStruct> swiftObj;
        APIStruct(std::shared_ptr<BasicTest::APIStruct> swiftObj);
        APIStruct(const UnmanagedBasicTest::APIEnum& enumValue);
        ~APIStruct();

        UnmanagedBasicTest::APIEnum getEnumValue();
    };

    class APIClass {
    private:
    public:
        std::shared_ptr<BasicTest::APIClass> swiftObj;
        APIClass(std::shared_ptr<BasicTest::APIClass> swiftObj);
        APIClass();
        ~APIClass();

        std::string getText();
        std::string sayHello(const std::string& name);
        UnmanagedBasicTest::APIStruct doWork(const UnmanagedBasicTest::APIStruct& structValue);
    };

    class APIEnum {
    private:
    public:
        std::shared_ptr<BasicTest::APIEnum> swiftObj;
        APIEnum(std::shared_ptr<BasicTest::APIEnum> swiftObj);
        APIEnum(int rawValue);
        ~APIEnum();

        static UnmanagedBasicTest::APIEnum caseOne();
        static UnmanagedBasicTest::APIEnum caseTwo();

        bool operator==(const UnmanagedBasicTest::APIEnum& other) const;

        bool isCaseOne();
        bool isCaseTwo();
        int getRawValue();
    };
}

#endif /* UnmanagedBasicTest_hpp */