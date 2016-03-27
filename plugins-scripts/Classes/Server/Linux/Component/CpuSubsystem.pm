package Classes::Server::Linux::Component::CpuSubsystem;
our @ISA = qw(Classes::Server::Linux);
use strict;

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  $self->init();
  return $self;
}

sub init {
  my $self = shift;
  $self->{cpu_subsystem} =
      Classes::UCDMIB::Component::CpuSubsystem->new();
  $self->{cpu_subsystem}->unix_init();
}

sub check {
  my $self = shift;
  $self->{cpu_subsystem}->check();
  $self->{cpu_subsystem}->unix_check();
}

sub dump {
  my $self = shift;
  $self->{cpu_subsystem}->dump();
  $self->{cpu_subsystem}->unix_dump();
}


1;
