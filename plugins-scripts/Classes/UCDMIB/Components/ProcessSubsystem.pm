package Classes::UCDMIB::Component::ProcessSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('UCD-SNMP-MIB', [
      ['processes', 'prTable', 'Classes::UCDMIB::Component::ProcessSubsystem::Process']
  ]);
}

package Classes::UCDMIB::Component::ProcessSubsystem::Process;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf '%s: %d%s',
      $self->{prNames},
      $self->{prCount},
      $self->{prErrorFlag} ? sprintf ' (%s)', $self->{prErrMessage} : '');
  my $threshold = sprintf '%u:%s',
      !$self->{prMin} && !$self->{prMax} ? 1 : $self->{prMin},
      $self->{prMax} && $self->{prMax} >= $self->{prMin} ? $self->{prMax} : '';
  $self->set_thresholds( warning => $threshold, critical => $threshold);
  if ($self->{prErrorFlag}) {
    $self->add_message(Monitoring::GLPlugin::CRITICAL);
  } else {
    $self->add_message($self->check_thresholds($self->{prCount}));
  }
  $self->add_perfdata(
      label => $self->{prNames},
      value => $self->{prCount}
  );
}

