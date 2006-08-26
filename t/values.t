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

#
# I don't quite get the details, but Perl's operator map and overload.pm's
# operator map are different, and ther's a tiny corner case where they can fall
# out of sync. Class::Constant < 0.03 used to tickle that case, so overloading
# wasn't working. Unfortunately, Test::More digs into overload.pm internals to
# find the stringification method rather than just letting Perl sort it out,
# and so it was reporting that stringification was working even when it wasn't.
#
# Our bug was fixed in 0.03, and a bug has been filed against Test::More.
# Until its sorted, we'll be forcing Perl to do the stringification and passing
# the result into Test::More.
#

my $x;

$x = "".stringify::NORTH;   is($x, "north");
$x = "".stringify::SOUTH;   is($x, "south");
$x = "".stringify::EAST;    is($x, "east");
$x = "".stringify::WEST;    is($x, "west");

is(methodify::NORTH->get_x,  0); is(methodify::NORTH->get_y, -1);
is(methodify::SOUTH->get_x,  0); is(methodify::SOUTH->get_y,  1);
is(methodify::EAST ->get_x, -1); is(methodify::EAST ->get_y,  0);
is(methodify::WEST ->get_x,  1); is(methodify::WEST ->get_y,  0);

$x = "".bothify::NORTH;     is($x, "north");
$x = "".bothify::SOUTH;     is($x, "south");
$x = "".bothify::EAST;      is($x, "east");
$x = "".bothify::WEST;      is($x, "west");

is(bothify::NORTH->get_x,  0); is(bothify::NORTH->get_y, -1);
is(bothify::SOUTH->get_x,  0); is(bothify::SOUTH->get_y,  1);
is(bothify::EAST ->get_x, -1); is(bothify::EAST ->get_y,  0);
is(bothify::WEST ->get_x,  1); is(bothify::WEST ->get_y,  0);
