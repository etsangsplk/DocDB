#
#        Name: $RCSfile$
# Description: Database routines to deal with document revisions
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

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
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub FetchDocRevisionByID ($) {

  # FIXME Change name to FetchDocumentRevision
  # FIXME Doesn't fetch obsolete revisions. Can't see why this would hurt. Investigate
  # Creates two hashes:
  # $DocRevIDs{DocumentID}{Version} holds the DocumentRevision ID
  # $DocRevisions{DocRevID}{FIELD} holds the Fields or references too them

  my ($DocRevID) = @_;
  my $RevisionList = $dbh->prepare(
    "select SubmitterID,DocumentTitle,PublicationInfo,VersionNumber,".
           "Abstract,RevisionDate,TimeStamp,DocumentID,Obsolete, ".
           "Keywords,Note,Demanaged,DocTypeID ".
    "from DocumentRevision ".
    "where DocRevID=? and Obsolete=0");
  if ($DocRevisions{$DocRevID}{DOCID} && $DocRevisions{$DocRevID}{Complete}) {
    return $DocRevisions{$DocRevID}{DOCID};
  }
  $RevisionList -> execute($DocRevID);
  my ($SubmitterID,$DocumentTitle,$PublicationInfo,
      $VersionNumber,$Abstract,$RevisionDate,
      $TimeStamp,$DocumentID,$Obsolete,
      $Keywords,$Note,$Demanaged,$DocTypeID) = $RevisionList -> fetchrow_array;

  #FIXME Make keys mixed-caps

  $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
  $DocRevisions{$DocRevID}{Submitter}     = $SubmitterID;
  $DocRevisions{$DocRevID}{Title}         = $DocumentTitle;
  $DocRevisions{$DocRevID}{PUBINFO}       = $PublicationInfo;
  $DocRevisions{$DocRevID}{Abstract}      = $Abstract;
  $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;  # FIXME: BWC
  $DocRevisions{$DocRevID}{Date}          = $RevisionDate;
  $DocRevisions{$DocRevID}{TimeStamp}     = $TimeStamp;
  $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber; # FIXME: BWC
  $DocRevisions{$DocRevID}{Version}       = $VersionNumber;
  $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
  $DocRevisions{$DocRevID}{Obsolete}      = $Obsolete;
  $DocRevisions{$DocRevID}{Keywords}      = $Keywords;
  $DocRevisions{$DocRevID}{Note}          = $Note;
  $DocRevisions{$DocRevID}{Demanaged}     = $Demanaged;
  $DocRevisions{$DocRevID}{DocTypeID}     = $DocTypeID;
  $DocRevisions{$DocRevID}{Complete}      = 1;

### Find earliest instance this document for content modification date

  my $EarliestVersionQuery = $dbh->prepare(
    "select DocRevID,RevisionDate ".
    "from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? order by DocRevID");
  $EarliestVersionQuery -> execute($DocumentID,$VersionNumber);

### Pull off first one

  my (undef,$VersionDate) = $EarliestVersionQuery -> fetchrow_array;
  $DocRevisions{$DocRevID}{VersionDate}   = $VersionDate;

  return $DocRevID;
}

sub FetchRevisionByDocumentAndVersion ($$) {
  require "DocumentSQL.pm";

  my ($DocumentID,$VersionNumber) = @_;
  &FetchDocument($DocumentID);
  my $RevisionQuery = $dbh->prepare(
    "select DocRevID from DocumentRevision ".
    "where DocumentID=? and VersionNumber=? and Obsolete=0");
  if ($DocRevIDs{$DocumentID}{$VersionNumber}) {
    return $DocRevIDs{$DocumentID}{$VersionNumber};
  }
  $RevisionQuery -> execute($DocumentID,$VersionNumber);
  my ($DocRevID) = $RevisionQuery -> fetchrow_array;
  push @DebugStack,"From Database DRI: $DocRevID DI: $DocumentID V: $VersionNumber";

  &FetchDocRevisionByID($DocRevID);

  return $DocRevID;
}

sub FetchRevisionByDocumentAndDate ($$) {
  require "DocumentSQL.pm";

  my ($DocumentID,$Date) = @_;
  &FetchDocument($DocumentID);
  my $RevisionQuery = $dbh -> prepare(
    "select MAX(VersionNumber) from DocumentRevision ".
    "where DocumentID=? and RevisionDate<=?");

  $Date .= " 23:59:59";
  $RevisionQuery -> execute($DocumentID,$Date);
  my ($Version) = $RevisionQuery -> fetchrow_array;

  my $DocRevID = &FetchRevisionByDocumentAndVersion($DocumentID,$Version);

  return $DocRevID;
}

sub FetchRevisionsByDocument {
  require "DocumentSQL.pm";

  my ($DocumentID) = @_;
  &FetchDocument($DocumentID);
  my $revision_list = $dbh->prepare(
    "select DocRevID from DocumentRevision where DocumentID=? and Obsolete=0");

  my ($DocRevID);
  $revision_list -> execute($DocumentID);

  $revision_list -> bind_columns(undef, \($DocRevID));

  my @DocRevList = ();
  while ($revision_list -> fetch) {
    &FetchDocRevisionByID($DocRevID);
    unless ($DocRevisions{$DocRevID}{Obsolete}) {
      push @DocRevList,$DocRevID;
    }
  }
  return @DocRevList;
}

sub GetAllRevisions { # FIXME: Implement full mode, flag with got all revisions
  my ($Mode) = @_;
  unless ($Mode) {$Mode = "brief"}; # Other modes not implemented yet
  my $revision_list = $dbh->prepare(
    "select DocRevID,SubmitterID,DocumentTitle,VersionNumber,".
           "RevisionDate,DocumentID,Obsolete ".
    "from DocumentRevision ".
    "where Obsolete=0");
  %DocRevIDs = ();
  %DocRevisions = ();
  $revision_list -> execute;
  $revision_list -> bind_columns(undef, \($DocRevID,$SubmitterID,$DocumentTitle,$VersionNumber,$RevisionDate,$DocumentID,$Obsolete));
  while ($revision_list -> fetch) {
    $DocRevIDs{$DocumentID}{$VersionNumber} = $DocRevID;
    $DocRevisions{$DocRevID}{Submitter}     = $SubmitterID;
    $DocRevisions{$DocRevID}{Title}         = $DocumentTitle;
    $DocRevisions{$DocRevID}{DATE}          = $RevisionDate;
    $DocRevisions{$DocRevID}{VERSION}       = $VersionNumber; # FIXME: BWC
    $DocRevisions{$DocRevID}{Version}       = $VersionNumber;
    $DocRevisions{$DocRevID}{DOCID}         = $DocumentID;
    $DocRevisions{$DocRevID}{Obsolete}      = $Obsolete;
    $DocRevisions{$DocRevID}{Complete}      = 0;
  }
}

sub FetchRevisionsByEventID {
  my ($EventID) = @_;

  my $DocRevID;
  my @DocRevIDs = ();

  my $RevisionList = $dbh -> prepare("select DocRevID from RevisionEvent where ConferenceID=?");

  $RevisionList -> execute($EventID);
  $RevisionList -> bind_columns(undef, \($DocRevID));

  while ($RevisionList -> fetch) {
    &FetchDocRevisionByID($DocRevID);
    if ($DocRevisions{$DocRevID}{Obsolete}) {next;}
    push @DocRevIDs,$DocRevID;
  }
  return @DocRevIDs;
}

sub UpdateRevision (%) { # Later add other fields, where clause
  require "SQLUtilities.pm";

  my %Params = @_;

  my $DocRevID = $Params{-docrevid};
  my $DateTime = $Params{-datetime} || &SQLNow();


  my $Update = $dbh -> prepare("update DocumentRevision set RevisionDate=? where DocRevID=?");
  $Update -> execute ($DateTime,$DocRevID);
}

sub InsertRevision {

  my %Params = @_;

  my $DocumentID    = $Params{-docid}         || "";
  my $SubmitterID   = $Params{-submitterid}   || 0;
  my $Title         = $Params{-title}         || "";
  my $Abstract      = $Params{-abstract}      || "";
  my $Keywords      = $Params{-keywords}      || "";
  my $Note          = $Params{-note}          || "";
  my $PubInfo       = $Params{-pubinfo}       || "";
  my $DateTime      = $Params{-datetime}           ;
  my $Version       = $Params{-version}       || 0;
  my $DocTypeID     = $Params{-doctypeid}     || 0;

  unless ($DateTime) {
    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  }

  my $MakeObsolete = $FALSE;
  if ($Version ne "bump" && $Version ne "reserve") {
    $MakeObsolete = $TRUE;
  }

  $NewVersion = $Version;

  if ($Version eq "bump" || $Version eq "latest") {
    my $Found = FetchDocument($DocumentID);
    $NewVersion = int($Documents{$DocumentID}{NVersions});
    if ($Version eq "bump") {
      ++$NewVersion;
    }
  } elsif ($Version eq "reserve") {
    $NewVersion = 0;
  }

  my $DocRevID = 0;

  if ($DocumentID) {
    if ($MakeObsolete) {
      my $Update = $dbh -> prepare("update DocumentRevision set Obsolete=1 ".
                                   "where DocumentID=? and VersionNumber=?");
      $Update -> execute($DocumentID,$NewVersion);
    }

    my $Insert = $dbh -> prepare("insert into DocumentRevision ".
       "(DocRevID, DocumentID, SubmitterID, DocumentTitle, PublicationInfo, ".
       " VersionNumber, Abstract, RevisionDate,Keywords,Note,DocTypeID) ".
       "values (0,?,?,?,?,?,?,?,?,?,?)");
    $Insert -> execute($DocumentID,$SubmitterID,$Title,$PubInfo,$NewVersion,
                       $Abstract,$DateTime,$Keywords,$Note,$DocTypeID);

    $DocRevID = $Insert -> {mysql_insertid}; # Works with MySQL only
  }

  return $DocRevID;
}

1;
