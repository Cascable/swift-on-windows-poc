// This is an auto-generated file. Do not modify.

#ifndef UnmanagedBasicTest_hpp
#define UnmanagedBasicTest_hpp
#include <memory>
#include <string>
#include <optional>

namespace BasicTest {
    class APIStruct;
    class WorkType;
    class APIClass;
    class APIEnum;
}

namespace UnmanagedBasicTest {

    class APIStruct;
    class WorkType;
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

    class WorkType {
    private:
    public:
        std::shared_ptr<BasicTest::WorkType> swiftObj;
        WorkType(std::shared_ptr<BasicTest::WorkType> swiftObj);
        ~WorkType();

        static std::optional<UnmanagedBasicTest::WorkType> initWithRawValue(int rawValue);

        static UnmanagedBasicTest::WorkType returnValue();
        static UnmanagedBasicTest::WorkType returnNil();

        bool operator==(const UnmanagedBasicTest::WorkType& other) const;

        bool isReturnValue();
        bool isReturnNil();
        int getRawValue();
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
        std::optional<std::string> doOptionalWork(const UnmanagedBasicTest::WorkType& type, const std::optional<std::string>& optionalString);
    };

    class APIEnum {
    private:
    public:
        std::shared_ptr<BasicTest::APIEnum> swiftObj;
        APIEnum(std::shared_ptr<BasicTest::APIEnum> swiftObj);
        ~APIEnum();

        static std::optional<UnmanagedBasicTest::APIEnum> initWithRawValue(int rawValue);

        static UnmanagedBasicTest::APIEnum caseOne();
        static UnmanagedBasicTest::APIEnum caseTwo();

        bool operator==(const UnmanagedBasicTest::APIEnum& other) const;

        bool isCaseOne();
        bool isCaseTwo();
        int getRawValue();
    };
}

#endif /* UnmanagedBasicTest_hpp */
