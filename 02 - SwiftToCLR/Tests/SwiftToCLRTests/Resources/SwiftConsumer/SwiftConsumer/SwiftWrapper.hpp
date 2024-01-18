// This is an auto-generated file. Do not modify.
#ifndef SwiftWrapper_hpp
#define SwiftWrapper_hpp
#include <memory>
#include <string>

namespace BasicTest {
    class APIStruct;
    class APIClass;
    class APIEnum;
    class APIProtocol;
}

namespace SwiftWrapper {

    class APIStruct;
    class APIClass;
    class APIEnum;
    class APIProtocol;

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

        bool isCaseOne();
        bool isCaseTwo();
        int getRawValue();
    };

    class APIProtocol {
    private:
    public:
        std::shared_ptr<BasicTest::APIProtocol> swiftObj;
        APIProtocol(std::shared_ptr<BasicTest::APIProtocol> swiftObj);
        ~APIProtocol();

    };
}

#endif /* SwiftWrapper_hpp */
