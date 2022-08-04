###############################################################################
#
#  WookeeSmile.pm
#
#  Created by Michael Buschbeck <michael.buschbeck@gmx.de>
#  Free for use and modification.
#
#  Wookee character formatter for friendly emoticons.
#
#  $Author: tarquin $ $Date: 2003/05/04 22:01:14 $ $Revision: 1.3 $
#

use Wookee;


###############################################################################
#
#  CharacterEmoticon
#
#  Replaces emoticon character sequences by graphical emoticons.
#

{
  package CharacterEmoticon;
  

  ###########################################################
  #
  #  Static
  #
  
  sub TRUE  () { 1 }
  sub FALSE () { 0 }
  
  our @ISA = Character;
  
  our $emoticonDir     = '/www/wiki/www/wiki-ext/emoticons';
  our $emoticonAddress = '/wiki-ext/emoticons';
  our $emoticonPattern;
  our %emoticonFile;

  our %emoticonSimple = (
    'smile'   => [ ':-)', ':)', '=)' ],
    'wink'    => [ ';-)', ';)'       ],
    'biggrin' => [ ':-D', ':D', '=D' ],
    'tongue'  => [ ':-p', ':p', '=p' ],
    'sad'     => [ ':-(', ':(', '=(' ],
    'hmm'     => [ ':-/', ':/', '=/' ],
    'ohoh'    => [ 'o_O', 'O_o'      ],
    );
  
  CharacterEmoticon->register();


  ###########################################################
  #
  #  Initialization
  #
  
  INIT {
  
    my $emoticonFile;
    my $emoticonSimple;
    my $emoticonSimpleFound;
    my $emoticonToken;

    $emoticonPattern = ':(?:';

    opendir EMOTICONS, $emoticonDir
      or return;

    foreach $emoticonFile (grep /\.(?:png|gif|jpe?g)$/i, readdir EMOTICONS) {
      $emoticonToken = lc $emoticonFile;
      $emoticonToken =~ s/\.\w+$//;
      
      $emoticonFile{':'. $emoticonToken .':'} = $emoticonFile;
      $emoticonPattern .= "\Q$emoticonToken\E|";
      }

    closedir EMOTICONS;
    
    $emoticonPattern =~ s/\|$//;
    $emoticonPattern .= '):';
    
    foreach $emoticonSimple (map lc, keys %emoticonSimple) {
      next
        unless defined $emoticonFile{':'. $emoticonSimple .':'};
    
      foreach $emoticonToken (map lc, @{$emoticonSimple{$emoticonSimple}}) {
        $emoticonFile{lc $emoticonToken} = $emoticonFile{':'. $emoticonSimple .':'};
        $emoticonPattern .= '|(?:^|(?<=\\W))('
          unless $emoticonSimpleFound;
        $emoticonPattern .= "\Q$emoticonToken\E|";
        $emoticonSimpleFound = TRUE;
        }
      }

    $emoticonPattern =~ s/\|$/)/;
    }


  ###########################################################
  #
  #  tokenFind $text
  #

  sub tokenFind {
  
    my $self = shift;
    my $text = shift;

    return ()
      unless %emoticonFile;
    
    $text =~ /($emoticonPattern)/i
      or return ();
    
    $self->{tokenType} = $1;
    
    return ($-[0], $+[0] - $-[0], 0);
    }


  ###########################################################
  #
  #  tokenClose $chunk
  #
  
  sub tokenClose {
  
    my $self = shift;
    my $chunk = shift;
    
    my $tokenType;

    $tokenType = pop @{$self->{tokenStack}};
    
    return qq[<img alt="$tokenType" src="$emoticonAddress/$emoticonFile{lc $tokenType}" align="middle">];
    }
}
  
