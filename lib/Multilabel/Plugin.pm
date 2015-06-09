# $Id$

package Multilabel::Plugin;

use strict;
use warnings;

sub plugin {
    return MT->component('Multilabel');
}

1;
