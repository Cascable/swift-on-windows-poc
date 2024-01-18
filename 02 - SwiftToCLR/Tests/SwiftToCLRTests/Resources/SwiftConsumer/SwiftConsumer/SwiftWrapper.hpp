// This is an auto-generated file. Do not modify.
#ifndef SwiftWrapper_hpp
#define SwiftWrapper_hpp
#include <memory>
#include <string>

namespace BasicTest {
    class APIStruct;
    class APIClass;
    class APIEnum;
}

namespace SwiftWrapper {

    class APIStruct;
    class APIClass;
    class APIEnum;

    class APIStruct {
    private:
    public:
        std::shared_ptr<BasicTest::APIStruct> swiftObj;
        APIStruct(std::shared_ptr<BasicTest::APIStruct> swiftObj);
        APIStruct(const SwiftWrapper::APIEnum & enumValue);
        ~APIStruct();

        SwiftWrapper::APIEnum getEnumValue();
    };

    class APIClass {
    private:
    public:
        std::shared_ptr<BasicTest::APIClass> swiftObj;
        APIClass(std::shared_ptr<BasicTest::APIClass> swiftObj);
        APIClass();
        ~APIClass();

        std::string getText();
        std::string sayHello(const std::string & name);
        SwiftWrapper::APIStruct doWork(const SwiftWrapper::APIStruct & structValue);
    };

    class APIEnum {
    private:
    public:
        std::shared_ptr<BasicTest::APIEnum> swiftObj;
        APIEnum(std::shared_ptr<BasicTest::APIEnum> swiftObj);
        ~APIEnum();

        static APIEnum caseOne();
        static APIEnum caseTwo();

        bool operator==(const SwiftWrapper::APIEnum &other) const;

        bool isCaseOne();
        bool isCaseTwo();
        int getRawValue();
    };
}

#endif /* SwiftWrapper_hpp */
