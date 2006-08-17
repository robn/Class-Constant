#!perl -T

use Test::More 'no_plan';


package stringify;

use Class::Constant
    NORTH => "north",
    SOUTH => "south",
    EAST  => "east",
    WEST  => "west";


package methodify;

use Class::Constant
    NORTH => { x =>  0, y => -1 },
    SOUTH => { x =>  0, y =>  1 },
    EAST  => { x => -1, y =>  0 },
    WEST  => { x =>  1, y =>  0 };


package bothify;

use Class::Constant
    NORTH => "north",
             { x =>  0, y => -1 },
    SOUTH => "south",
             { x =>  0, y =>  1 },
    EAST  => "east",
             { x => -1, y =>  0 },
    WEST  => "west",
             { x =>  1, y =>  0 };


package main;

# we do this because Test::More does overload stringification manually by
# digging into overload.pm internals, rather than letting happen. so when it
# didn't work, these tests still passed :(

my $x;

$x = "".stringify::NORTH;   is($x, "north");
$x = "".stringify::SOUTH;   is($x, "south");
$x = "".stringify::EAST;    is($x, "east");
$x = "".stringify::WEST;    is($x, "west");

is(methodify::NORTH->x,  0); is(methodify::NORTH->y, -1);
is(methodify::SOUTH->x,  0); is(methodify::SOUTH->y,  1);
is(methodify::EAST ->x, -1); is(methodify::EAST ->y,  0);
is(methodify::WEST ->x,  1); is(methodify::WEST ->y,  0);

$x = "".bothify::NORTH;     is($x, "north");
$x = "".bothify::SOUTH;     is($x, "south");
$x = "".bothify::EAST;      is($x, "east");
$x = "".bothify::WEST;      is($x, "west");

is(bothify::NORTH->x,  0); is(bothify::NORTH->y, -1);
is(bothify::SOUTH->x,  0); is(bothify::SOUTH->y,  1);
is(bothify::EAST ->x, -1); is(bothify::EAST ->y,  0);
is(bothify::WEST ->x,  1); is(bothify::WEST ->y,  0);
