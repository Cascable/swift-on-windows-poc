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

    Console.WriteLine(instance.getText());
    Console.WriteLine(instance.sayHello(name));

}
