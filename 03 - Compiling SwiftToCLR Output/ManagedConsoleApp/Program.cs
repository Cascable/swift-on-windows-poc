using ManagedBasicTest;

Console.WriteLine("What's your name?");
string? name = Console.ReadLine();

if (name != null)
{
    APIEnum enumValue = APIEnum.caseOne();
    if (enumValue.isCaseOne())
    {
        Console.WriteLine("Case one!");
    } else if (enumValue.isCaseTwo())
    {
        Console.WriteLine("Case two!");
    }

    bool isOne = (enumValue == APIEnum.caseOne());
    if (isOne)
    {
        Console.WriteLine("Case one (again)!");
    }

    APIEnum rawCreated = APIEnum.initWithRawValue(1);
    if (rawCreated != null) { Console.WriteLine("Enum with raw value 1 success!"); }
    APIEnum rawCreatedShouldBeNull = APIEnum.initWithRawValue(5);
    if (rawCreatedShouldBeNull == null) { Console.WriteLine("Enum with raw value 5 success! (as in, it's null)"); }

    int rawValue = enumValue.getRawValue();
    Console.WriteLine(rawValue);
    Console.WriteLine(APIEnum.caseTwo().getRawValue());

    APIClass instance = new APIClass();
    APIStruct structValue = new APIStruct(APIEnum.caseTwo());
    APIStruct returnedStructValue = instance.doWork(structValue);
    bool structsMatch = (structValue.getEnumValue() == returnedStructValue.getEnumValue());
    if (structsMatch)
    {
        Console.WriteLine("Match!");
    }

    string optionalResult = instance.doOptionalWork(WorkType.returnNil(), null);
    if (optionalResult == null)
    {
        Console.WriteLine("optionalResult is null (as it should be)");
    } else
    {
        Console.WriteLine(optionalResult);
    }
    

    string optionalResult2 = instance.doOptionalWork(WorkType.returnValue(), "value");
    Console.WriteLine(optionalResult2);

    Console.WriteLine(instance.getText());
    Console.WriteLine(instance.sayHello(name));

}
