package Filesystem::Transactional::Wrapper;
use Moose;

has 'delegate' => (
    is       => 'ro',
    isa      => 'Class',
    required => 1,
);

sub can {
    my $self = shift;
    return $self->delegate->can(@_);
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ /::(<method>\w+)$/;
    my $method = $+{method};
    my @ret = eval {
        $self->delegate->$method(@_);
    };
    if ($@){
        return 1;
    }
    else {
        if(@ret == 1 && $ret[0] == 1){
            return 0;
        }
        return @ret;
    }
}

1;
