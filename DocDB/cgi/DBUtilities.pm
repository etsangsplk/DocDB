#
# Description: Routines to open and close DB 
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2005 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

sub CreateConnection (%) { 
  my %Params = @_;
  
  require "Messages.pm";
  
  #FIXME: Use this routine
  #FIXME: Change dbh_w to dbh_rw in TalkNote(?) routine(s)
  
  my $Type     = $Params{-type} || "ro";
  my $User     = $Params{-user};
  my $Password = $Params{-password};
  
  push @DebugStack,"Connecting to DB in user/password mode failed.";
  if ($User && $Password) {
    push @DebugStack,"Connecting to DB in user/password mode";
    $dbh = DBI -> connect('DBI:mysql:'.$db_name.':'.$db_host,$User,$Password) 
                || push @ErrorStack,$Msg_AdminNoConnect;
    unless ($dbh) {
      push @DebugStack,"Connecting to DB in user/password mode failed.";
    }  
  } elsif ($Type eq "ro") {
    $dbh_ro   = DBI -> connect('DBI:mysql:'.$db_name.':'.$db_host,$db_rouser,$db_ropass) 
                || push @ErrorStack,$Msg_NoConnect;
    unless ($dbh) {
      $dbh = $dbh_ro;
    }
  } elsif ($Type eq "rw") {
    $dbh_ro   = DBI -> connect('DBI:mysql:'.$db_name.':'.$db_host,$db_rouser,$db_ropass) 
                || push @ErrorStack,$Msg_NoConnect;
    $dbh_rw   = DBI -> connect('DBI:mysql:'.$db_name.':'.$db_host,$db_rwuser,$db_rwpass) 
                || push @ErrorStack,$Msg_NoConnect;
    unless ($dbh) {
      $dbh = $dbh_rw;
    }
  } 
  
  return $dbh;          
};

sub DestroyConnection ($) {
  my ($DBH) = @_;
  
  $DBH -> disconnect;
}
  
1;
