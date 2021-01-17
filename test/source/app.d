import diff;

import std.stdio;

void main()
{
    auto v = new V!int(30, 50, true, true);

    writeln(v);

    auto v2 = v.createCopy(1, true, 0);

    writeln(v2);

    auto s = new Snake!int(true, 5);

    writeln(s);

    auto snakePair = new SnakePair!int(5, new Snake!int(true, 5), new Snake!int(false, 5));
}
