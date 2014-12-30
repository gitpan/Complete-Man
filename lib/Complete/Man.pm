package Complete::Man;

our $DATE = '2014-12-30'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;
#use Log::Any '$log';

use Complete;

our %SPEC;
require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(complete_manpage);

$SPEC{complete_manpage} = {
    v => 1.1,
    summary => 'Complete from list of available manpages',
    description => <<'_',

For each directory in `MANPATH` environment variable, search man section
directories and man files.

_
    args => {
        word => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        ci => {
            summary => 'Whether to do case-insensitive search',
            schema  => 'bool*',
        },
        section => {
            summary => 'Only search from this section',
            schema  => 'str*',
        },
    },
    result_naked => 1,
};
sub complete_manpage {
    require Complete::Util;
    require Filename::Compressed;

    my %args = @_;

    my $sect = $args{section};
    if (defined $sect) {
        $sect = "man$sect" unless $sect =~ /\Aman/;
    }

    return [] unless $ENV{MANPATH};

    my @res;
    for my $dir (split /:/, $ENV{MANPATH}) {
        next unless -d $dir;
        opendir my($dh), $dir or next;
        for my $sectdir (readdir $dh) {
            next unless $sectdir =~ /\Aman/;
            next if $sect && $sect ne $sectdir;
            opendir my($dh), "$dir/$sectdir" or next;
            my @files = readdir($dh);
            for my $file (@files) {
                next if $file eq '.' || $file eq '..';
                my $chkres = Filename::Compressed::check_compressed_filename(
                    filename => $file,
                );
                my $name = $chkres ? $chkres->{uncompressed_filename} : $file;
                $name =~ s/\.\w+\z//; # strip section name
                push @res, $name;
            }
        }
    }
    Complete::Util::complete_array_elem(
        word => $args{word},
        array => \@res,
        ci => $args{ci},
    );
}

1;
# ABSTRACT: Complete from list of available manpages

__END__

=pod

=encoding UTF-8

=head1 NAME

Complete::Man - Complete from list of available manpages

=head1 VERSION

This document describes version 0.01 of Complete::Man (from Perl distribution Complete-Man), released on 2015-12-30.

=head1 SYNOPSIS

 use Complete::Man qw(complete_manpage);

 my $res = complete_manpage(word => 'gre');
 # -> ['grep', 'grep-changelog', 'greynetic', 'greytiff']

 # only from certain section
 $res = complete_manpage(word => 'gre', section => 1);
 # -> ['grep', 'grep-changelog', 'greytiff']

=head1 FUNCTIONS


=head2 complete_manpage(%args) -> any

Complete from list of available manpages.

For each directory in C<MANPATH> environment variable, search man section
directories and man files.

Arguments ('*' denotes required arguments):

=over 4

=item * B<ci> => I<bool>

Whether to do case-insensitive search.

=item * B<section> => I<str>

Only search from this section.

=item * B<word>* => I<str>

=back

Return value:

 (any)

=head1 TODO

Read/parse C<index.db>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Complete-Man>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Complete-Man>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Complete-Man>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
