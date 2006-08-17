package Class::Constant;

use warnings;
use strict;

our $VERSION = '0.04';

my %ordinal_for_data;
my %data_by_ordinal;

sub import {
    my ($pkg, @args) = @_;

    my $caller = caller;

    $ordinal_for_data{$caller} ||= 0;

    my $start_ordinal = $ordinal_for_data{$caller};

    my %data;
    my $value = 0;
    for my $arg (@args) {
        if ($arg =~ /^[A-Z][A-Z0-9_]*$/) {
            if (exists $data{name}) {
                my %data_copy = %data;
                $data_by_ordinal{$caller}->[$data{ordinal}] = \%data_copy;
            }

            %data = ();

            $data{name} = $arg;

            $data{ordinal} = $ordinal_for_data{$caller};
            $ordinal_for_data{$caller}++;

            $data{object} = \do { my $x = $data{ordinal} };

            $data{value} = $value;
            $value++;

            next;
        }

        if (ref $arg eq "HASH") {
            $data{methods} = $value = $arg;
            $value++;

            next;
        }

        $data{value} = $value = $arg;
        $value++;
    }

    if (exists $data{name}) {
        my %data_copy = %data;
        $data_by_ordinal{$caller}->[$data{ordinal}] = \%data_copy;
    }

    for my $ordinal ($start_ordinal .. $ordinal_for_data{$caller}-1) {
        my $data = $data_by_ordinal{$caller}->[$ordinal];

        do {
            no strict "refs";
            *{$caller."::".$data->{name}} = sub { bless $data->{object}, $caller };
        };
    }

    if ($start_ordinal == 0 and $ordinal_for_data{$caller} > 0) {
        do {
            no strict "refs";

            unshift @{$caller."::ISA"}, "Class::Constant::Value";

            *{$caller."::by_ordinal"} = sub {
                return if @_ < 2;
                if (not exists $data_by_ordinal{$caller}->[$_[1]]) {
                    require Carp;
                    Carp::croak("Can't locate constant with ordinal \"$_[1]\" in package \"".(ref($_[0])||$_[0])."\"");
                }
                return bless $data_by_ordinal{$caller}->[$_[1]]->{object}, $caller;
            };
        };
    }
}


package Class::Constant::Value;

use Scalar::Util qw(refaddr);

use overload
    q{""} => sub { (shift)->as_string(@_) },
    q{==} => sub { (shift)->equals(@_) },
    q{!=} => sub { !(shift)->equals(@_) };

sub as_string {
    return "$data_by_ordinal{ref $_[0]}->[${$_[0]}]->{value}";
}

sub equals {
    return (ref $_[0] eq ref $_[1] && refaddr $_[0] == refaddr $_[1]) ? 1 : 0;
}

sub get_ordinal {
    return ${$_[0]};
}

sub AUTOLOAD {
    my ($self) = @_;

    use vars qw($AUTOLOAD);
    my ($pkg, $method) = $AUTOLOAD =~ m/^(.*)::(.*)/;

    return if $method =~ m/^[A-Z]+$/;

    my $data = $data_by_ordinal{ref $_[0]}->[${$_[0]}];
    return if not $data;

    if (not exists $data->{methods} or not exists $data->{methods}->{$method}) {
        require Carp;
        Carp::croak("Can't locate named constant \"$method\" for \"" .ref($_[0]). "::$data->{name}\"");
    }

    return $data->{methods}->{$method};
}

1;

__END__

=head1 NAME

Class::Constant - Build constant classes

=head1 SYNOPSIS

    use Class::Constant NORTH, SOUTH, EAST, WEST;
    
    use Class::Constant
        NORTH => "north",
        SOUTH => "south",
        EAST  => "east",
        WEST  => "west;
    
    use Class::Constant
        NORTH => { x =>  0, y => -1 },
        SOUTH => { x =>  0, y =>  1 },
        EAST  => { x => -1, y =>  0 },
        WEST  => { x =>  1, y =>  0 };
    
    use Class::Constant
        NORTH => "north",
                 { x =>  0, y => -1 },
        SOUTH => "south",
                 { x =>  0, y =>  1 },
        EAST  => "east",
                 { x => -1, y =>  0 },
        WEST  => "west",
                 { x =>  1, y =>  0 };

=head1 DESCRIPTION

Class::Constant allows you to declaratively created so-called "constant
classes" (something like "typesafe enumerations" in Java).

The simplest example of creating a constant class is like so:

    package Direction;
    use Class::Constant NORTH, SOUTH, EAST, WEST;

You'd might then use this in your application like so:

    use Direction;
    
    my $facing = Direction::NORTH;
    
    ...

    if ($facing == Direction::SOUTH) {
        move_south();
    }

Each constant has an internal ordinal value. These values are unique
per-package, and are generated sequentially. So in the example above, the
constants would have the following ordinal values:

    NORTH   0
    SOUTH   1
    EAST    2
    WEST    3

You can get the ordinal value for a constant using the C<get_ordinal> method:

    my $ordinal = SOUTH->get_ordinal;

Additionally, you can get a constant value back given the ordinal value using
the C<by_ordinal> method:

    my $direction = Direction->by_ordinal(2);

By default, objects stringify to their ordinal value. You set your own string
for any given constant like so:

    use Class::Constant
        NORTH => "north",
        SOUTH => "south",
        EAST  => "east",
        WEST  => "west;

    ...

    print "You are facing $facing.\n";

You can also associate named values with a constant by using a hashref:

    use Class::Constant
        NORTH => { x =>  0, y => -1 },
        SOUTH => { x =>  0, y =>  1 },
        EAST  => { x => -1, y =>  0 },
        WEST  => { x =>  1, y =>  0 };

    ...

    print "About to move ".
          $facing->x." in x and ".
          $facing->y." in y.";

And of course, you can do both:

    use Class::Constant
        NORTH => "north",
                 { x =>  0, y => -1 },
        SOUTH => "south",
                 { x =>  0, y =>  1 },
        EAST  => "east",
                 { x => -1, y =>  0 },
        WEST  => "west",
                 { x =>  1, y =>  0 };

    ...

    print "Moving $facing will move you ".
          $facing->x." in x and ".
          $facing->y." in y.";

=head1 AUTHOR

Robert Norris (rob@cataclysm.cx)

=head1 BUGS

This documentation probably sucks; I found it exceptionally difficult to
explain what I was trying to do here.

=head1 COPYRIGHT

Copyright (c) 2006 Robert Norris. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.
