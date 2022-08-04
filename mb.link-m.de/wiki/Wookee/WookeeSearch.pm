###############################################################################
#
#  WookeeSearch.pm
#
#  Created by Michael Buschbeck <michael.buschbeck@gmx.de>
#  Free for use and modification.
#
#  Provides a paragraph class that inserts a Wiki search form.
#
#  $Author: mychaeel $ $Date: 2002/06/16 23:35:27 $ $Revision: 1.4 $
#

use Wookee;


###############################################################################
#
#  ParagraphSearch
#
#  Inserts a Wiki search form with a customizable caption.
#

{
  package ParagraphSearch;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propMarkup    { '@search@' }
  sub propParaStart { qq[<form class="parasearch" method=post action="$UseModWiki::ScriptName">] }
  sub propParaEnd   { qq[</form>] }
  
  sub TRUE  () { 1 }
  sub FALSE () { 0 }

  ParagraphSearch->register();
  

  ###########################################################
  #
  #  findSeparator $chunk
  #

  sub findSeparator { 
  
    my $self = shift;
    my $chunk = shift;
  
    my $offsetInput;
    my $offsetSubmit;
  
    $offsetInput  = $-[0] if $chunk =~ /\@input\@/  and not $self->{haveInput};
    $offsetSubmit = $-[0] if $chunk =~ /\@submit\@/ and not $self->{haveSubmit};

    if (defined $offsetInput) {
      if (defined $offsetSubmit and $offsetSubmit < $offsetInput) {
        $self->{type} = SUBMIT;
        return ($offsetSubmit, 8);
        }
      
      $self->{type} = INPUT;
      return ($offsetInput, 7);
      }

    elsif (defined $offsetSubmit) {
      $self->{type} = SUBMIT;
      return ($offsetSubmit, 8);
      }

    return ();
    }


  ###########################################################
  #
  #  addSeparator
  #

  sub addSeparator {
  
    my $self = shift;
  
    my $search;
    
    for ($self->{type}) {
      /INPUT/ and do {
        $search = &UseModWiki::GetParam('search', '');

        $search =~ s[&] [&amp;]g;
        $search =~ s["] [&quot;]g;
        $search =~ s[<] [&lt;]g;
        $search =~ s[>] [&gt;]g;
  
        $self->addUnparsed(qq[<input type=text name="search" value="$search">]);
        last;
        };

      /SUBMIT/ and do {
        $self->addUnparsed(qq[<input type=submit value="Search">]);
        last;
        };
      }

    $self->{haveInput} = TRUE;
    }
}