package WWW::Search::Googlism;

use 5.006;
use strict;
use warnings;
require Exporter;
our @ISA = qw(WWW::Search Exporter);
our $VERSION = '0.01';
use Carp;
use WWW::Search qw/generic_option/;
require WWW::SearchResult;

my $MAINTAINER = 'xern <xern@cpan.org>';

sub native_setup_search {
    my($self, $native_query, $native_options_ref) = @_;
    $self->{_debug} = $native_options_ref->{'search_debug'};
    $self->{_debug} = 0 if (!defined($self->{_debug}));
    $self->{agent_e_mail} = 'xern@cpan.org';
    $self->user_agent('WWW::Search::Googlism Agent');
    $self->{_next_to_retrieve} = 1;
    $self->{'_num_hits'} = 0;

    if (!defined($self->{_options})) {
        $self->{'search_base_url'} = 'http://www.googlism.com/';
        $self->{_options} = {
	    'search_url' => 'http://www.googlism.com/index.htm',
	    'ism' => $native_query,
	};
    }
    my $options_ref = $self->{_options};
    if (defined($native_options_ref)){
        foreach (keys %$native_options_ref)
	{
	    $options_ref->{$_} = $native_options_ref->{$_};
	}
    }
    my($options) = '';
    foreach (sort keys %$options_ref)
    {
	next if (generic_option($_));
	croak("Unknown option") unless $_ eq 'ism' || $_ eq 'type';
	my %dict = qw/who 1 what 2 where 3 when 4/;
	if( $_ eq 'type' ){
	    croak("Invalid type") unless $dict{$options_ref->{'type'}};
	    $options_ref->{'type'} = $dict{$options_ref->{'type'}};
	}
	$options .= $_ . '=' . $options_ref->{$_} . '&';
    }
    chop $options;
    $self->{_next_url} = $self->{_options}{'search_url'}.'?'.$options;
#    print $self->{_next_url};
}

sub native_retrieve_some {
    my ($self) = @_;
    return unless $self->{_next_url};
    my($response) = $self->http_request('GET', $self->{_next_url});
    $self->{response} = $response;
    $response->{_content} =~ m!<br><h1><span class="suffix">Googlism for:</span> .+?</h1><br>(.+)<br>\n!s;
    my ($hit, $hits_found);
    for my $r (split /<br>\n/, $1){
	$hit = new WWW::SearchResult;
	$hits_found++;
	$hit->title($r);
	push @{$self->{cache}}, $hit;
    }
    undef $self->{_next_url};
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

WWW::Search::Googlism - Searching Googlism

=head1 SYNOPSIS

  use WWW::Search::Googlism;
  $query = "googlism";
  $search = new WWW::Search('Googlism');
  $search->native_query(WWW::Search::escape_query($query), { type => 'who' });
  while (my $result = $search->next_result()) {
      $title = $result->title;
      print "<a href=$url>$title</a>\n";
  }


=head1 DESCRIPTION

WWW::Search::Googlism is a subclass of WWW::Search. Users can use this module to search http://www.googlism.com/.

=head1 TYPES

Four types of searching Googlism are "who is", "what is", "where is", and "when is". Specify it with parameter 'type'.

=head1 AUTHOR

xern <xern@cpan.org>

=head1 LICENSE

Released under The Artistic License

=head1 SEE ALSO

B<WWW::Search>

=cut
