use Test;
BEGIN { plan tests => 1 }
END   { ok($loaded) }
use Lingua::FR::Numbers qw( number_to_fr );
$loaded++;
