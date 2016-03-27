package Classes::UCDMIB::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('UCD-SNMP-MIB', [
      ['disks', 'dskTable', 'Classes::UCDMIB::Component::DiskSubsystem::Disk',
          sub {
            return shift->{dskDevice} !~ /^(sysfs|proc|udev|devpts|rpc_pipefs|nfsd)$/;
          }
      ],
  ]);
}

package Classes::UCDMIB::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  # support large disks > 2tb
  my $free = 100 * $self->{dskAvail} / $self->{dskTotal};
  $free = 100 - $self->{dskPercent} if $self->{dskTotal} >= 2147483647;
  # define + set threshold
  my $warn = 10;
  my $crit = 5;
  if ($self->{dskMinPercent} >= 0) {
    $warn = $self->{dskMinPercent}.':';
    $crit = $warn;
  } elsif ($self->{dskMinimum} >= 0 && $self->{dskTotal} < 2147483647) {
    $warn = sprintf '%.2f:', 100 * $self->{dskMinimum} / $self->{dskTotal};
    $crit = $warn;
  }
  $self->set_thresholds(
      metric => sprintf('%s_free_pct', $self->{dskPath}),
      warning => $warn, critical => $crit);
  # send info
  $self->add_info(sprintf 'disk %s has %.2f%% free space left%s',
      $self->{dskPath},
      $free,
      $self->{dskErrorFlag} ? sprintf ' (%s)', $self->{dskErrorMsg} : '');
  # set error level if needed
  if ($self->{dskErrorFlag}) {
    $self->add_message(Monitoring::GLPlugin::CRITICAL);
  } else {
    $self->add_message($self->check_thresholds(
        metric => sprintf('%s_free_pct', $self->{dskPath}),
        value => $free));
  }
  $self->add_perfdata(
      label => sprintf('%s_free_pct', $self->{dskPath}),
      value => $free,
      uom => '%',
  );
}

