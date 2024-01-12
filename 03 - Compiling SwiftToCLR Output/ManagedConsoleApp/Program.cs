using ManagedWrapper;

Console.WriteLine("What's your name?");
string? name = Console.ReadLine();

if (name != null)
{
    UnmanagedAPI api = new UnmanagedAPI();
    Console.WriteLine(api.Greet(name));
}
