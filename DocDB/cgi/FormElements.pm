#
#        Name: FormElements.pm
# Description: Various routines which supply input forms for document 
#              addition, etc. This file is deprecated. Routines are 
#              being moved out into the various *HTML.pm files.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 
#

# Copyright 2001-2006 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "TopicHTML.pm";

sub DaysPulldown (;$) {
  my ($DefaultDays) = @_;
  unless ($DefaultDays) { 
    $DefaultDays = $LastDays;
  }  
  my @Days = (1,2,3,5,7,10,14,20,30,45,60,90,120,180 );
  print $query -> popup_menu (-name    => 'days', -values   => \@Days,
                              -default => $DefaultDays,  -onChange => "submit()");
}

sub DateTimePulldown (%) { # Note capitalization
  my (%Params) = @_;
  
  my $Name        = $Params{-name}        || "date";
  my $Disabled    = $Params{-disabled}    || 0;
  my $DateOnly    = $Params{-dateonly}    || 0;
  my $TimeOnly    = $Params{-timeonly}    || 0;
  my $OneTime     = $Params{-onetime}     || 0;
  my $OneLine     = $Params{-oneline}     || 0;
  my $Granularity = $Params{-granularity} || 5;
  
  my $Default     = $Params{-default};

  my $HelpLink  = $Params{-helplink}  || "";
  my $HelpText  = $Params{-helptext}  || "Date &amp; Time";
  my $Required  = $Params{-required}  || 0;
  my $NoBreak   = $Params{-nobreak}  ;
  my $ExtraText = $Params{-extratext};
   
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
  $Year += 1900;
  $Min = (int (($Min+($Granularity/2))/$Granularity))*$Granularity; # Nearest $Granularity minutes

  my $DefaultHHMM;
  if ($Default) {
    my ($DefaultDate,$DefaultTime);
    if ($DateOnly) { 
      $DefaultDate = $Default;
    } elsif ($TimeOnly) {
      $DefaultTime = $Default;
    } else {
      ($DefaultDate,$DefaultTime) = split /\s+/,$Default;
    }  

    ($Year,$Mon,$Day) = split /-/,$DefaultDate;
    $Day  = int($Day);
    $Mon  = int($Mon);
    $Year = int($Year);
    --$Mon;
    ($Hour,$Min,$Sec) = split /:/,$DefaultTime;
    $Hour = int($Hour);
    $Min  = int($Min);
    $Sec  = int($Sec);
    $DefaultHHMM = sprintf "%2.2d:%2.2d",$Hour,$Min;
  }
  
  my @Years = ();
  for (my $i = $FirstYear; $i<=$Year+1; ++$i) { # $FirstYear - current year + 1
    push @Years,$i;
  }  

  my @Days = ();
  for (my $i = 1; $i<=31; ++$i) { # $FirstYear - current year
    push @Days,$i;
  }  

  my @Hours = ();
  for (my $i = 0; $i<24; ++$i) {
    push @Hours,$i;
  }  

  my @Minutes = ();
  for (my $i = 0; $i<=55; $i=$i+5) {
    push @Minutes,(sprintf "%2.2d",$i);
  }  
  
  my @Times = ();
  for (my $Hour = 0; $Hour<=23; ++$Hour) {
    for (my $Min = 0; $Min<=59; $Min=$Min+$Granularity) {
      push @Times,sprintf "%2.2d:%2.2d",$Hour,$Min;
    }  
  }  
  
  my $ElementTitle = &FormElementTitle(-helplink  => $HelpLink , 
                                       -helptext  => $HelpText ,
                                       -extratext => $ExtraText,
                                       -text      => $Text     ,
                                       -nobreak   => $NoBreak  ,
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     

  unless ($DateOnly) {
    if ($OneTime) {
      print $query -> popup_menu (-name => $Name."time", -values => \@Times,   -default => $DefaultHHMM, $Booleans);
    } else {
      print $query -> popup_menu (-name => $Name."hour", -values => \@Hours,   -default => $Hour, $Booleans);
      print "<b> : </b>\n";
      print $query -> popup_menu (-name => $Name."min",  -values => \@Minutes, -default => $Min, $Booleans);
    }
  }
  unless ($OneLine || $DateOnly || $TimeOnly) {
    print "<br\>\n";
  } 
  if ($OneLine) {
    print "&nbsp;\n";
  } 
  unless ($TimeOnly) {
    print $query -> popup_menu (-name => $Name."day",-values => \@Days, -default => $Day, $Booleans);
    print $query -> popup_menu (-name => $Name."month",-values => \@AbrvMonths, -default => $AbrvMonths[$Mon], $Booleans);
    print $query -> popup_menu (-name => $Name."year",-values => \@Years, -default => $Year, $Booleans);
  }
}

sub DateTimePullDown { #FIXME: Replace with DateTimePulldown
  my ($sec,$min,$hour,$day,$mon,$year) = localtime(time);
  $year += 1900;
  $min = (int (($min+3)/5))*5; # Nearest five minutes
  
  my @days = ();
  for ($i = 1; $i<=31; ++$i) {
    push @days,$i;
  }  

  my @months = ("Jan","Feb","Mar","Apr","May","Jun",
             "Jul","Aug","Sep","Oct","Nov","Dec");

  my @years = ();
  for ($i = $FirstYear; $i<=$year; ++$i) { # $FirstYear - current year
    push @years,$i;
  }  

  my @hours = ();
  for ($i = 0; $i<24; ++$i) {
    push @hours,$i;
  }  

  my @minutes = ();
  for ($i = 0; $i<=55; $i=$i+5) {
    push @minutes,(sprintf "%2.2d",$i);
  }  
  
  print "<b><a ";
  &HelpLink("overdate");
  print "Date &amp; Time:</a></b><br> \n";
  print $query -> popup_menu (-name => 'overday',-values => \@days, -default => $day);
  print $query -> popup_menu (-name => 'overmonth',-values => \@months, -default => $months[$mon]);
  print $query -> popup_menu (-name => 'overyear',-values => \@years, -default => $year);
  print "<br>\n";
  print $query -> popup_menu (-name => 'overhour',-values => \@hours, -default => $hour);
  print "<b> : </b>\n";
  print $query -> popup_menu (-name => 'overmin',-values => \@minutes, -default => $min);
}

sub PubInfoBox {
  my $ElementTitle = &FormElementTitle(-helplink  => "pubinfo", 
                                       -helptext  => "Other publication information");
  print $ElementTitle,"\n";                                     

  print $query -> textarea (-name => 'pubinfo', -default => $PubInfoDefault,
                            -columns => 60, -rows => 3);
};

sub TopicSelect { # V8OBS Scrolling selectable list for topics
  my (%Params) = @_;
  
  my $Required = $Params{-required} || 0;
  #FIXME: Use TopicScroll
  my @TopicIDs = sort byTopic keys %MinorTopics;
  my %TopicLabels = ();
  foreach my $ID (@TopicIDs) {
    $TopicLabels{$ID} = $MinorTopics{$ID}{Full};
  }
  my $ElementTitle = &FormElementTitle(-helplink  => "topics", 
                                       -helptext  => "Topics",
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     
  print $query -> scrolling_list(-name => "topics", -values => \@TopicIDs, 
                                 -labels => \%TopicLabels,
                                 -size => 10, -multiple => 'true',
                                 -default => \@TopicDefaults);
};

sub MultiTopicSelect (%) {# V8OBS # Multiple scrolling selectable lists for topics
  require "TopicSQL.pm";
  
  my (%Params) = @_;
  
  my $Required = $Params{-required}  || 0;
  my $Disabled = $Params{-disabled}  || "";

  my $NCols = 4;
  my @MajorIDs = sort byMajorTopic keys %MajorTopics;
  my @MinorIDs = keys %MinorTopics;

  print "<table cellpadding=5>\n";
  print "<tr><td colspan=$NCols align=center>\n";
  my $ElementTitle = &FormElementTitle(-helplink  => "topics", 
                                       -helptext  => "Topics",
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     
  my $Col = 0;
  foreach $MajorID (@MajorIDs) {
    unless ($Col % $NCols) {
      print "<tr valign=top>\n";
    }
    print "<td><b>$MajorTopics{$MajorID}{SHORT}</b><br/>\n";
    ++$Col;
    my @MatchMinorIDs = ();
    my %MatchLabels = ();
    foreach my $MinorID (@MinorIDs) {
      if ($MinorTopics{$MinorID}{MAJOR} == $MajorID) {
        push @MatchMinorIDs,$MinorID;
        $MatchLabels{$MinorID} = $MinorTopics{$MinorID}{SHORT};
      }  
    }
    @MatchMinorIDs = sort byTopic @MatchMinorIDs;

    #FIXME: Use TopicScroll
    if ($Disabled) { # Doesn't scale
      print $query -> scrolling_list(-name => "topics", 
               -values => \@MatchMinorIDs, -labels => \%MatchLabels,
               -size => 8, -multiple => 'true', -default => \@TopicDefaults,
               -disabled);
    } else {
      print $query -> scrolling_list(-name => "topics", 
               -values => \@MatchMinorIDs, -labels => \%MatchLabels,
               -size => 8, -multiple => 'true', -default => \@TopicDefaults);
    }               
    print "</td>\n";
  }  
  print "</table>\n";
};

sub MajorTopicSelect (%) { # V8OBS# Scrolling selectable list for major topics
  my (%Params) = @_;
  
  my $Mode     = $Params{-format}    || "short";
  my $Disabled = $Params{-disabled}  || "0";
  
  print FormElementTitle(-helplink => "majortopics", -helptext => "Major Topics");

  my @MajorIDs = keys %MajorTopics;
  my %MajorLabels = ();
  foreach my $ID (@MajorIDs) {
    if ($Mode eq "full") {
      $MajorLabels{$ID} = $MajorTopics{$ID}{Full};
    } else {  
      $MajorLabels{$ID} = $MajorTopics{$ID}{SHORT};
    }  
  } 
  if ($Disabled) {  # Doesn't scale
    print $query -> scrolling_list(-name => "majortopic", -values => \@MajorIDs, 
                                   -labels => \%MajorLabels,  -size => 10,
                                   -disabled);
  } else {
    print $query -> scrolling_list(-name => "majortopic", -values => \@MajorIDs, 
                                   -labels => \%MajorLabels,  -size => 10);
  }                               
                                 
};

sub InstitutionSelect (;%) { # Scrolling selectable list for institutions
  require "Sorts.pm";

  my (%Params) = @_;
  
  my $Mode     = $Params{-format}    || "short";
  my $Disabled = $Params{-disabled}  || "0";
  my $Required = $Params{-required}  || $FALSE;
  
  my $ExtraText;
  if ($Mode eq "full") {$ExtraText = "(Long descriptions in brackets)";}
  
  
  my $ElementTitle = &FormElementTitle(-helplink  => "institution", 
                                       -helptext  => "Institution",
                                       -extratext => $ExtraText,
                                       -required  => $Required);
  print $ElementTitle,"\n";                                     

  my @InstIDs = sort byInstitution keys %Institutions;
  my %InstLabels = ();
  foreach my $ID (@InstIDs) {
    if ($Mode eq "full") {
      $InstLabels{$ID} = $Institutions{$ID}{SHORT}." [".$Institutions{$ID}{LONG}."]";
    } else {
      $InstLabels{$ID} = $Institutions{$ID}{SHORT};
    }
  } 
  if ($Disabled) { 
    print $query -> scrolling_list(-name => "inst", -values => \@InstIDs,
                                   -labels => \%InstLabels,  -size => 10,
                                   -disabled);
  } else {
    print $query -> scrolling_list(-name => "inst", -values => \@InstIDs,
                                   -labels => \%InstLabels,  -size => 10);
  }
};

sub NameEntryBox (;%) {
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<table class=\"MedPaddedTable\"><tr>\n";
  print "<td>\n";
  my $ElementTitle = FormElementTitle(-helplink  => "authorentry", 
                                      -helptext  => "First Name",
                                      -required  => $TRUE);
  print $ElementTitle,"\n";                                     
  print $query -> textfield (-name => 'first', 
                             -size => 20, -maxlength => 32,$Booleans);
  print "</td></tr>\n";
  print "<tr><td>\n";
  $ElementTitle = FormElementTitle(-helplink  => "authorentry", 
                                   -helptext  => "Middle Initial(s)");
  print $ElementTitle,"\n";                                     
  print $query -> textfield (-name => 'middle', 
                             -size => 10, -maxlength => 16,$Booleans);
  print "</td></tr>\n";
  print "<tr><td>\n";
  $ElementTitle = FormElementTitle(-helplink  => "authorentry", 
                                   -helptext  => "Last Name",
                                   -required  => $TRUE);
  print $ElementTitle,"\n";                                     
  print $query -> textfield (-name => 'lastname', 
                             -size => 20, -maxlength => 32,$Booleans);
  print "</td>\n";
  print "</tr></table>\n";
}

sub UpdateButton {
  my ($DocumentID) = @_;

#  unless (&CanModify) {return;}

  $query -> param('mode','update'); 
  $query -> param('docid',$DocumentID);

  print $query -> startform('POST',$DocumentAddForm);
  print "<div>\n";
  print $query -> hidden(-name => 'mode',  -default => 'update');
  print $query -> hidden(-name => 'docid', -default => $DocumentID);
  print $query -> submit (-value => "Update Document");
  print "\n</div>\n";
  print $query -> endform;
  print "\n";
}

sub UpdateDBButton {
  my ($DocumentID,$Version) = @_;
  
#  unless (&CanModify) {return;}

  $query -> param('mode',   'updatedb');
  $query -> param('docid',  $DocumentID);
  $query -> param('version',$Version);
  
  print $query -> startform('POST',$DocumentAddForm);
  print "<div>\n";
  print $query -> hidden(-name =>    'mode', -default => 'updatedb');
  print $query -> hidden(-name =>   'docid', -default => $DocumentID);
  print $query -> hidden(-name => 'version', -default => $Version);
  print $query -> submit (-value => "Update DB Info");
  print "\n</div>\n";
  print $query -> endform;
  print "\n";
}

sub AddFilesButton {
  my ($DocumentID,$Version) = @_;

#  unless (&CanModify) {return;}

  $query -> param('docid',$DocumentID);
  $query -> param('version',$Version);
  
  print $query -> startform('POST',$AddFilesForm);
  print "<div>\n";
  print $query -> hidden(-name => 'docid',   -default => $DocumentID);
  print $query -> hidden(-name => 'version', -default => $Version);
  print $query -> submit (-value => "Add Files");
  print "\n</div>\n";
  print $query -> endform;
  print "\n";
}

sub AuthorManual (%) { # FIXME: Special case of AuthorTextEntry
  my (%Params) = @_;
  
  my $Required  =   $Params{-required}  || 0;

  $AuthorManDefault = "";

  foreach $AuthorID (@AuthorDefaults) {
    $AuthorManDefault .= "$Authors{$AuthorID}{FULLNAME}\n" ;
  }
    
  print "<b><a ";
  &HelpLink("authormanual");
  print "Authors:</a></b>";
  if ($Required) {
    print $RequiredMark;
  }  
  print "<br> \n";
  
  print $query -> textarea (-name    => 'authormanual', 
                            -default => $AuthorManDefault,
                            -columns => 20, -rows    => 8);
};

sub ReferenceForm {
  require "MiscSQL.pm";
  
  &GetJournals;

  my @JournalIDs = keys %Journals;
  my %JournalLabels = ();
  foreach my $ID (@JournalIDs) {
    $JournalLabels{$ID} = $Journals{$ID}{Acronym};
  }
  @JournalIDs = sort @JournalIDs;  #FIXME Sort by acronym
  unshift @JournalIDs,0; $JournalLabels{0} = "----"; # Null Journal
  my $ElementTitle = &FormElementTitle(-helplink  => "reference", 
                                       -helptext  => "Journal References");
  print $ElementTitle,"\n";                                     

  my @ReferenceIDs = (@ReferenceDefaults,0);
  
  print "<table cellpadding=3>\n";
  foreach my $ReferenceID (@ReferenceIDs) { 
    print "<tr>\n";
    my $JournalDefault = $RevisionReferences{$ReferenceID}{JournalID};
    my $VolumeDefault  = $RevisionReferences{$ReferenceID}{Volume}   ;
    my $PageDefault    = $RevisionReferences{$ReferenceID}{Page}     ;
    print "<td><b>Journal: </b>\n";
    print $query -> popup_menu(-name => "journal", -values => \@JournalIDs, 
                                   -labels => \%JournalLabels,
                                   -default => $JournalDefault);

    print "<td><b>Volume:</b> \n";
    print $query -> textfield (-name => 'volume', 
                               -size => 8, -maxlength => 8, 
                               -default => $VolumeDefault);

    print "<td><b>Page:</b> \n";
    print $query -> textfield (-name => 'page', 
                               -size => 8, -maxlength => 16, 
                               -default => $PageDefault);
    print "</tr>\n";                           
  }
  print "</table>\n";
}

sub TextField (%) {  
  my (%Params) = @_;
  
  my $HelpLink  = $Params{-helplink} ;
  my $HelpText  = $Params{-helptext} ;
  my $ExtraText = $Params{-extratext};
  my $Text      = $Params{-text}     ;
  my $NoBreak   = $Params{-nobreak}  ;
  my $Required  = $Params{-required} ;
  my $Name      = $Params{-name}      || "";
  my $Default   = $Params{-default}   || "";
  my $Size      = $Params{-size}      || 40;
  my $MaxLength = $Params{-maxlength} || 240;
  my $Disabled  = $Params{-disabled}  || 0;
    
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  

  my $ElementTitle = &FormElementTitle(-helplink  => $HelpLink , 
                                       -helptext  => $HelpText ,
                                       -extratext => $ExtraText,
                                       -text      => $Text     ,
                                       -nobreak   => $NoBreak  ,
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     
  print $query -> textfield (-name => $Name, -default   => $Default, 
                             -size => $Size, -maxlength => $MaxLength, $Booleans);
} 

sub TextArea (%) {  
  require "Utilities.pm";
  my (%Params) = @_;
  
  my $HelpLink  = $Params{-helplink} ;
  my $HelpText  = $Params{-helptext} ;
  my $ExtraText = $Params{-extratext};
  my $Text      = $Params{-text}     ;
  my $NoBreak   = $Params{-nobreak}  ;
  my $Required  = $Params{-required} ;
  my $Name      = $Params{-name}      || "";
  my $Default   = $Params{-default}   || "";
  my $Columns   = $Params{-columns}   || 40;
  my $Rows      = $Params{-rows}      || 6;
  
  my $ElementTitle = &FormElementTitle(-helplink  => $HelpLink , 
                                       -helptext  => $HelpText ,
                                       -extratext => $ExtraText,
                                       -text      => $Text     ,
                                       -nobreak   => $NoBreak  ,
                                       -required  => $Required );
  print $ElementTitle,"\n";                                     
  print $query -> textarea (-name    => $Name,    -default   => &SafeHTML($Default), 
                            -columns => $Columns, -rows      => $Rows);
} 

sub FormElementTitle (%) {  
  my (%Params) = @_;
  
  my $HelpLink  = $Params{-helplink}  || "";
  my $HelpText  = $Params{-helptext}  || "";
  my $ExtraText = $Params{-extratext} || "";
  my $Text      = $Params{-text}      || "";
  my $NoBreak   = $Params{-nobreak}   || 0;
  my $NoBold    = $Params{-nobold}    || 0;
  my $NoColon   = $Params{-nocolon}   || 0;
  my $Required  = $Params{-required}  || 0;

  my $TitleText = "";
  my $Colon     = "";
  
  unless ($HelpLink || $Text) {
    return $TitleText;
  }  
  
  unless ($NoColon) {
    $Colon = ":";
  }  
  unless ($NoBold) {
    $TitleText .= "<strong>";
  }
  if ($HelpLink) {
    $TitleText .= "<a class=\"Help\" href=\"Javascript:helppopupwindow(\'$DocDBHelp?term=$HelpLink\');\">";
    $TitleText .= "$HelpText$Colon</a>";
  } elsif ($Text) {
    $TitleText .= "$Text$Colon"; 
  }
  unless ($NoBold) {
    $TitleText .= "</strong>";
  }
  
  if ($Required) {
    $TitleText .= $RequiredMark;
  } 
   
  if ($ExtraText) {
    $TitleText .= "&nbsp;$ExtraText";
  } 
  
  if ($NoBreak) { 
#    $TitleText .= "\n";
  } else {
    $TitleText .= "<br/>\n";
  }  
  
  return $TitleText;
}

1;
