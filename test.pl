use Test;
BEGIN { plan tests => 2 };
use WWW::Search::Googlism;
ok(1); # If we made it this far, we're ok.

$query = "bill gates";
$search = new WWW::Search('Googlism');
$search->native_query(WWW::Search::escape_query($query), { type => 'who' });
while (my $result = $search->next_result()) {
    $title = $result->title;
    $desc = $result->description;
    $text .= "<a href=$url>$title</a>\n";
}

ok(($text ? 1 : 0), 1);
