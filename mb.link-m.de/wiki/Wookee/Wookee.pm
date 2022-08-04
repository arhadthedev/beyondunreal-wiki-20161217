###############################################################################
#
#  Wookee.pm
#
#  Created by Michael Buschbeck <michael.buschbeck@gmx.de>
#  Free for use and modification.
#
#  Base architecture for a modular extensible Wiki formatter. Includes classes
#  that implement most of the standard Wiki formatting rules.
#
#  $Author: tarquin $ $Date: 2003/05/19 09:20:08 $ $Revision: 1.14 $
#


###############################################################################
#
#  class Block
#
#  Base class for block-level markup. Provides a method that eats as much of a
#  raw input stream as belongs to this block and calls other methods to process
#  this data. Subclass to implement specific blocks.
#

{
  package Block;
  
  
  ###########################################################
  #
  #  Static
  #
  
  our @registered;
  
  sub propTag    { undef }
  sub propType   { BLOCK }
  sub propNested { @registered }

  sub TRUE  () { 1 }
  sub FALSE () { 0 }


  ###########################################################
  #
  #  register
  #
  #  Registers this block markup class for use. Unless
  #  overridden by a specific subclass, all registered block
  #  classes are considered sub-blocks when parsing a block.
  #

  sub register {

    my $class = shift;  $class = (ref $class or $class);

    push @registered, $class
      if $class->isa(Block)
      and not grep /^\Q$class\E$/, @registered;
    }


  ###########################################################
  #
  #  new [$owner]
  #
  #  Creates a new Block object, initializes its variables
  #  and returns a reference to it. Inheritable.
  #
  
  sub new {
  
    my $class = shift;  $class = (ref $class or $class);
    my $owner = shift;

    my $self;
    
    $self->{owner}  = $owner;
    $self->{main}   = TRUE;
    $self->{start}  = TRUE;
    $self->{info}   = {};
    $self->{result} = undef;
    $self->{param}  = {};

    return bless $self, $class;
    }


  ###########################################################
  #
  #  info @keylist [= $value]
  #
  #  Retrieves or sets a value associated with the given
  #  key list. Propagated from sub-blocks to the main block.
  #  Used to store information gathered during parsing of
  #  the block.
  #
  
  sub info : lvalue {
  
    my $self = shift;
    
    my $inforef;
    
    if ($self->{owner}) {
      $inforef = \$self->{owner}->info(@_);
      }
    
    else {
      $inforef = \$self->{info};
      $inforef = \$$inforef->{shift()}
        while @_;
      }

    $$inforef;
    }


  ###########################################################
  #
  #  parseHeader  $text
  #  parseHeader \$text
  #
  #  Parses the header of this block and modifies the text
  #  argument if it is given as a reference. This method
  #  isn't called for the implicit main block. Implemented
  #  here for HTML-style block headers with optional
  #  parameters.
  #
  
  sub parseHeader {
  
    my $self = shift;
    my $text = shift;
    
    my $textref;
    my $tag;
    my $paramraw = '';
    
    $textref = (ref $text ? $text : \$text);
    
    $tag = $self->propTag();
    $$textref =~ s[^<\Q$tag\E(?>\s*)([^>]*)>] [$paramraw = $1; '']ie;
    
    $self->{main} = FALSE;
    $self->{param} = { map { defined and (/^("?)(.*)\1$/g)[1] or undef }
      $paramraw =~ m[("[^"]*"|[^\s=]+)(?:\s*=\s*("[^"]*"|\S+))?]g };
    }
  
  
  ###########################################################
  #
  #  parseBlock  $text
  #  parseBlock \$text
  #
  #  Bites as much of the given text off as belongs to this
  #  block, skipping and recursively parsing embedded blocks
  #  it choses to have interpreted. Calls addParsed and
  #  addUnparsed to process parseable and unparseable chunks
  #  of the text. Returns the formatted representation of the
  #  bitten-off part of the text, and modifies the text if
  #  it is passed as a scalar reference.
  #
  
  sub parseBlock {
  
    my $self = shift;
    my $text = shift;
    
    my $textref;
    my $endOffset;
    my $endLength;
    my $nestedBlock;
    my $nestedClass;
    my $nestedOffset;
    my $nestedText;
    
    $textref = (ref $text ? $text : \$text);
    
    undef $self->{result};

    while ($$textref) {
      ($endOffset, $endLength) = $self->findEnd($$textref);
      ($nestedClass, $nestedOffset) = $self->findNested($$textref);

      if ($nestedClass and $nestedOffset < $endOffset) {
        $self->addParsed(substr $$textref, 0, $nestedOffset);

        $nestedBlock = $nestedClass->new($self);
        $$textref = substr $$textref, $nestedOffset;
        $nestedBlock->parseHeader($textref);

        $nestedText = $nestedBlock->parseBlock($textref);
        $self->addBlock($nestedText, $nestedClass)
          if defined $nestedText;

        next;
        }

      if ($endOffset >= length $$textref or not $self->{main}) {
        $self->addParsed(substr $$textref, 0, $endOffset);
        $$textref = substr $$textref, $endOffset + $endLength
          if $endOffset + $endLength <= length $$textref;
        last;
        }

      $self->addParsed(substr $$textref, 0, $endOffset + $endLength);
      $$textref = substr $$textref, $endOffset + $endLength;
      }
    
    return $self->{result};
    }
  

  ###########################################################
  #
  #  findStart $text, $start
  #
  #  Finds the next start of a block of this type and returns
  #  the character index of it, or undef if none was found.
  #  Implemented here for HTML-style tags.
  #
  
  sub findStart {
  
    my $class = shift;  $class = (ref $class or $class);
    my $text = shift;
    my $start = shift;
    
    my $tag;
    
    $tag = $class->propTag();

    $text =~ m[<\Q$tag\E(?>\s*)[^>]*>]i
      or return undef;
    
    return $-[0];
    }
  
  
  ###########################################################
  #
  #  findNested $text
  #
  #  Finds the next start of a nested block and returns a
  #  list containing the character index of its start and its
  #  class, or an empty list if none was found.
  #
  
  sub findNested {
  
    my $self = shift;
    my $text = shift;
    
    my $nestedClass;
    my $nestedClassBest;
    my $nestedOffset;
    my $nestedOffsetBest;
    
    foreach $nestedClass ($self->propNested()) {
      $nestedOffset = $nestedClass->findStart($text, $self->{start});
      next
        unless defined $nestedOffset;
      
      ($nestedClassBest, $nestedOffsetBest) = ($nestedClass, $nestedOffset)
        if not defined $nestedClassBest
        or $nestedOffsetBest > $nestedOffset;
      }

    $self->{start} = FALSE;

    return ()
      unless defined $nestedClassBest;

    return ($nestedClassBest, $nestedOffsetBest);
    }
  
  
  ###########################################################
  #
  #  findEnd $text
  #
  #  Finds the end of the current block and returns a list
  #  containing its character index and its length, pointing
  #  behind the last character of the string if no end tag
  #  was found. Implemented here for HTML-style end tags.
  #
  
  sub findEnd {
  
    my $self = shift;
    my $text = shift;
    
    my $tag;
    
    $tag = $self->propTag();

    $text =~ m[</\Q$tag\E[^>]*>]i
      or return (length $text, 0);

    return ($-[0], $+[0] - $-[0]);
    }
  
  
  ###########################################################
  #
  #  addParsed $chunk
  #
  #  Parses the given text chunk and adds its formatted
  #  representation to the result accumulator.
  #
  
  sub addParsed {
  
    my $self = shift;
    my $chunk = shift;
    
    $self->{result} .= $chunk;
    }
  
  
  ###########################################################
  #
  #  addBlock $blockText, $blockClass
  #
  #  Adds the the result of a sub-block of the given class to
  #  the result accumulator without any further parsing.
  #
  
  sub addBlock {
  
    my $self = shift;
    my $blockText = shift;
    my $blockClass = shift;
 
    $self->{result} .= $blockText;
    }
}


###############################################################################
#
#  class BlockUnparsed
#
#  Block implementing completely unparsed text, save escape sequences for
#  special HTML characters. Nested blocks start and end tags are also left
#  unparsed, but must be balanced.
#

{
  package BlockUnparsed;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Block;

  sub propTag    { 'nowiki' }
  sub propType   { INLINE }
  sub propNested { () }

  sub TRUE  () { 1 }
  sub FALSE () { 0 }

  BlockUnparsed->register();


  ###########################################################
  #
  #  parseBlock  $text
  #  parseBlock \$text
  #

  sub parseBlock {
  
    my $self = shift;
    my $text = shift;

    my $textref;
    my $tag;
    my $tagLength;
    my $nesting;
    my $resultText;
    my $resultLength;
    
    $nesting = 1;
    $tag = $self->propTag();
    
    $textref = (ref $text ? $text : \$text);
    
    $nesting += ($1 ? -1 : +1)
      while $nesting > 0
      and $$textref =~ m[<(/?)\Q$tag\E\s*[^>]*>]ig;
    
    $resultLength = $-[0];
    if (defined $resultLength) {
      $tagLength = $+[0] - $resultLength;
      }
    
    else {
      $resultLength = length $$textref;
      $tagLength = 0;
      }
    
    $resultText = substr $$textref, 0, $resultLength;
    $$textref = substr $$textref, $resultLength + $tagLength;
    
    $resultText =~ s[&]  [&amp;]g;
    $resultText =~ s[<]  [&lt;]g;
    $resultText =~ s[>]  [&gt;]g;
    
    return $resultText;
    }
}


###############################################################################
#
#  class BlockUnparsedCode
#
#  Block implementing completely unparsed text in a monospaced font, inline.
#

{
  package BlockUnparsedCode;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = BlockUnparsed;

  sub propTag    { 'code' }
  sub propType   { INLINE }
  sub propNested { () }

  BlockUnparsedCode->register();


  ###########################################################
  #
  #  parseBlock  $text
  #  parseBlock \$text
  #

  sub parseBlock {
  
    my $self = shift;
    my $text = shift;

    return '<code>' . $self->SUPER::parseBlock($text) . '</code>';
    }
}


###############################################################################
#
#  class BlockUnparsedPreformatted
#
#  Block implementing completely unparsed text in a monospaced font, as block.
#

{
  package BlockUnparsedPreformatted;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = BlockUnparsed;

  sub propTag    { 'pre' }
  sub propType   { BLOCK }
  sub propNested { () }

  BlockUnparsedPreformatted->register();


  ###########################################################
  #
  #  parseBlock  $text
  #  parseBlock \$text
  #

  sub parseBlock {
  
    my $self = shift;
    my $text = shift;

    return '<pre>' . $self->SUPER::parseBlock($text) . '</pre>';
    }
}


###############################################################################
#
#  class BlockWiki
#
#  Block implementing Wiki paragraph and character markup.
#

{
  package BlockWiki;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Block;

  sub propTag  { 'wiki' }
  sub propPara { ParagraphDefault }

  sub TRUE  () { 1 }
  sub FALSE () { 0 }

  BlockWiki->register();


  ###########################################################
  #
  #  parseBlock  $text
  #  parseBlock \$text
  #

  sub parseBlock {
  
    my $self = shift;
    my $text = shift;

    $self->{paraStart} = TRUE;
    $self->{paraStack} = [];
    
    $self->SUPER::parseBlock($text);
    $self->paraCloseAll();

    return $self->{result};
    }


  ###########################################################
  #
  #  addParsed $chunk
  #

  sub addParsed {
  
    my $self = shift;
    my $chunk = shift;
    
    my $paraChunk;
    my @paraChunks;
    my $paraContinued;
    
    $chunk =~ tr[\r] []d;
    @paraChunks = split /\n+/, $chunk, -1;

    while (@paraChunks) {
      $paraChunk = shift @paraChunks;
      $paraContinued = $paraChunk =~ s/\s*\\\\$/\n/;

      $self->{paraStart}
        ? $self->paraAddFirst($paraChunk)
        : $self->paraAddNext ($paraChunk);
      
      $self->{paraStart} = (@paraChunks and not $paraContinued);
      }
    }


  ###########################################################
  #
  #  paraAddFirst $chunk
  #
  #  Called for the first chunk of a new paragraph.
  #

  sub paraAddFirst {
  
    my $self = shift;
    my $chunk = shift;

    my $paraStack;
    my @paraStackNested;
    my $paraClassMatch;
    my $paraClassNested;
    my $paraClassLast;
    my $paraLast;
    my $paraLastPrev;
    my $paraNested;

    $paraStack = $self->{paraStack};

    $paraClassMatch = 0;
    $paraClassMatch++
      while $paraClassMatch < @$paraStack
      and ref             $paraStack->[$paraClassMatch] ne $self->propPara()
      and $paraLastPrev = $paraStack->[$paraClassMatch]->markupParse(\$chunk, $self)
      and $paraLast     = $paraLastPrev;

    $paraClassLast = (ref $paraLast or $self->propPara());

    while ($paraClassLast eq $self->propPara() or
           $paraClassLast->propParaContent() eq BLOCK) {

      undef $paraNested;
      foreach $paraClassNested ($paraClassLast->propNested()) {
        $paraNested = $paraClassNested->markupParse(\$chunk, $self)
          or next;

        $paraNested->blockStart();
        push @paraStackNested, $paraNested;

        $paraLast      = $paraNested;
        $paraClassLast = ref $paraNested;
        last;
        }
      
      last unless $paraNested;
      }

    $paraLast = $self->propPara()->new($self)
      unless $paraLast;

    $paraClassMatch = 1
      if  not $paraClassMatch
      and not @paraStackNested
      and @$paraStack == 1
      and ref $paraStack->[0] eq $self->propPara();

    $self->paraClose(TRUE)
      while @$paraStack > $paraClassMatch;

    if (not @paraStackNested or $paraStackNested[-1] ne $paraLast) {
      $self->paraClose(FALSE)
        if @$paraStack;
      push @paraStackNested, $paraLast;
      $paraStackNested[-1]->blockStart()
        unless $paraClassMatch;
      }
    
    push @$paraStack, @paraStackNested;

    $self->paraAddNext($chunk);
    }


  ###########################################################
  #
  #  paraAddNext $chunk
  #
  #  Called for the chunks following the first chunk of a
  #  paragraph.
  #
  
  sub paraAddNext {
  
    my $self = shift;
    my $chunk = shift;
    
    my $paraStack;

    $paraStack = $self->{paraStack};
    $paraStack->[-1]->addParsed($chunk);
    }


  ###########################################################
  #
  #  paraClose $blockEnd
  #
  #  Closes the current paragraph, optionally including a
  #  block end.
  #

  sub paraClose {
  
    my $self = shift;
    my $blockEnd = shift;

    my $paraClosed;
    my $paraStack;

    $paraStack = $self->{paraStack};

    $paraClosed = pop @$paraStack;
    $paraClosed->blockEnd()
      if $blockEnd;
    
    return $paraStack->[-1]->addUnparsed($paraClosed->result())
      if @$paraStack;
    
    $self->{result} .= $paraClosed->result();
    }


  ###########################################################
  #
  #  paraCloseAll
  #
  #  Closes all open paragraphs.
  #
  
  sub paraCloseAll {
  
    my $self = shift;
    
    $self->paraClose(TRUE)
      while @{$self->{paraStack}};
    }


  ###########################################################
  #
  #  addBlock $blockText, $blockClass
  #

  sub addBlock {
  
    my $self = shift;
    my $blockText = shift;
    my $blockClass = shift;

    my $paraStack;
    
    $paraStack = $self->{paraStack};

    $self->paraClose(TRUE)
      while @$paraStack
      and $blockClass->propType() eq BLOCK
      and $paraStack->[-1]->propParaContent() ne BLOCK;

    if (not @$paraStack and $blockClass->propType() eq BLOCK) {
      $self->{result} .= $blockText;
      $self->{paraStart} = TRUE;
      }

    else {
      push @$paraStack, $self->propPara()->new($self)
        unless @$paraStack;
      
      $paraStack->[-1]->addUnparsed($blockText);
      $self->{paraStart} = FALSE;
      }
    }
}


###############################################################################
#
#  class BlockWikiQuote
#
#  Block implementing Wiki paragraph and character markup in a block quote
#  environment (and in paragraph markup disguise).
#

{
  package BlockWikiQuote;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = BlockWiki;

  sub propNested { grep !/BlockWikiQuote/, shift->SUPER::propNested() }

  sub TRUE  () { 1 }
  sub FALSE () { 0 }

  BlockWikiQuote->register();


  ###########################################################
  #
  #  parseHeader  $text
  #  parseHeader \$text
  #
  
  sub parseHeader {
  
    my $self = shift;
    my $text = shift;
  
    $self->{main} = FALSE;
    }


  ###########################################################
  #
  #  parseBlock  $text
  #  parseBlock \$text
  #

  sub parseBlock {
  
    my $self = shift;
    my $text = shift;
    
    return '<blockquote>'
         . $self->SUPER::parseBlock($text)
         . '</blockquote>';
    }


  ###########################################################
  #
  #  findStart $text, $start
  #

  sub findStart {
  
    my $class = shift;  $class = (ref $class or $class);
    my $text = shift;
    my $start = shift;

    return 0
      if $start
      and $text =~ /^>/;

    $text =~ /\n(>)/
      or return undef;
    
    return $-[1];
    }


  ###########################################################
  #
  #  findEnd $text
  #
  
  sub findEnd {
  
    my $self = shift;
    my $text = shift;

    $text =~ /(?:(?<=[^\r\n\\])|(?<=[^\r\n\\][^\r\n])|^)([\r\n]+)[^\r\n>]/
      or return (length $text, 0);
    
    return ($-[1], $+[1] - $-[1]);
    }


  ###########################################################
  #
  #  paraAddFirst $chunk
  #
  #  Called for the first chunk of a new paragraph.
  #

  sub paraAddFirst {
  
    my $self = shift;
    my $chunk = shift;

    $chunk =~ s/>\s*//;

    $self->SUPER::paraAddFirst($chunk);
    }
}


###############################################################################
#
#  class Paragraph
#
#  Base class for Wiki markup paragraph styles. A paragraph style is specified
#  by the first characters of that paragraph. Styles can be nested.
#

{
  package Paragraph;
  
  
  ###########################################################
  #
  #  Static
  #
  
  our @registered;
  
  sub propMarkup      { undef  }
  sub propBlockStart  { undef  }
  sub propBlockEnd    { undef  }
  sub propParaStart   { undef  }
  sub propParaEnd     { undef  }
  sub propParaContent { INLINE }
  sub propNested      { @registered }
  sub propChar        { Character }

  sub TRUE  () { 1 }
  sub FALSE () { 0 }
  

  ###########################################################
  #
  #  register
  #
  #  Registers this paragraph markup class for use by Wiki
  #  markup blocks. Unless specified otherwise by a
  #  Paragraph subclass, all Paragraph classes can be
  #  mutually nested.
  #

  sub register {

    my $class = shift;  $class = (ref $class or $class);

    push @registered, $class
      if $class->isa(Paragraph)
      and not grep /^\Q$class\E$/, @registered;
    }


  ###########################################################
  #
  #  new [$owner]
  #
  #  Creates a new Paragraph object, initializes its
  #  variables and returns a reference to it. Inheritable.
  #
  
  sub new {
  
    my $class = shift;  $class = (ref $class or $class);
    my $owner = shift;
    
    my $self;
    
    $self->{owner}      = $owner;
    $self->{result}     = undef;
    $self->{blockStart} = FALSE;
    $self->{blockEnd}   = FALSE;
    $self->{charObject} = {};
    $self->{charStack}  = [];

    return bless $self, $class;
    }


  ###########################################################
  #
  #  markupParse  $chunk, [$owner]
  #  markupParse \$chunk, [$owner]
  #
  #  Checks whether the given text chunk is the start of a
  #  paragraph of this class, and returns a new Paragraph
  #  object if appropriate or undef otherwise. If given a
  #  scalar reference, removes the markup from it.
  #
  
  sub markupParse {

    my $class = shift;  $class = (ref $class or $class);
    my $chunk = shift;
    my $owner = shift;

    my $chunkref;
    my $markup;
    
    $markup = $class->propMarkup();
    
    return undef
      unless defined $markup;
    
    $chunkref = (ref $chunk ? $chunk : \$chunk);
    $$chunkref =~ s/^\Q$markup\E\s*//
      or return undef;

    return $class->new($owner);
    }


  ###########################################################
  #
  #  blockStart
  #
  #  Adds whatever block start markup is necessary for a row
  #  of subsequent paragraphs of this class in front of the
  #  result accumulator.
  #
  
  sub blockStart {
  
    shift->{blockStart} = TRUE;
    }


  ###########################################################
  #
  #  blockEnd
  #
  #  Adds whatever block end markup is necessary after a row
  #  of subsequent paragraphs of this class to the end of the
  #  result accumulator.
  #
  
  sub blockEnd {
  
    shift->{blockEnd} = TRUE;
    }


  ###########################################################
  #
  #  addParsed $chunk
  #
  #  Parses the given text chunk and adds its formatted
  #  representation to the result accumulator.
  #
  
  sub addParsed {
  
    my $self = shift;
    my $chunk = shift;
    
    my $charObject;
    my $charObjectBest;
    my $charStack;
    my $charStackLast;
    my $charClass;
    my $charClassBest;
    my $charClassNested;
    my $charTokenLength;
    my $charTokenNesting;
    my $charTokenNestingBest;
    my $charTokenOffset;
    my $charTokenOffsetBest;
    
    $charObject = $self->{charObject};
    $charStack  = $self->{charStack};
    
    while ($chunk) {
      $charClass = (@$charStack ? ref $charStack->[-1]{object} : $self->propChar());

      undef $charClassBest;
      ($charTokenOffsetBest, $charTokenLengthBest) = $self->findSeparator($chunk);

      foreach $charClassNested ($charClass->propNested()) {
        $charObject->{$charClassNested} = $charClassNested->new($self)
          unless $charObject->{$charClassNested};

        ($charTokenOffset, $charTokenLength, $charTokenNesting) = $charObject->{$charClassNested}->tokenFind($chunk);
        
        next
          if not defined $charTokenOffset
          or (defined $charTokenOffsetBest
              and $charTokenOffsetBest <= $charTokenOffset);
        
        $charClassBest        = $charClassNested;
        $charTokenOffsetBest  = $charTokenOffset;
        $charTokenLengthBest  = $charTokenLength;
        $charTokenNestingBest = $charTokenNesting;
        }

      last
        unless defined $charTokenOffsetBest;

      $self->addUnparsed(substr $chunk, 0, $charTokenOffsetBest);
      $chunk = substr $chunk, $charTokenOffsetBest + $charTokenLengthBest;

      if (not defined $charClassBest) {
        $self->charClose();
        $self->addSeparator();
        }
        
      else {
        $charObjectBest = $charObject->{$charClassBest};
  
        if (not defined $charTokenNestingBest) {
          $charObjectBest->tokenOpen();
          push @$charStack, { object => $charObjectBest };
          }
  
        elsif ($charTokenNestingBest == 0) {
          $charObjectBest->tokenOpen();
          $self->addUnparsed($charObjectBest->tokenClose(undef));
          }
        
        else {
          while (@$charStack and $charTokenNestingBest > 0) {
            $charStackLast = pop @$charStack;
            $self->addUnparsed($charStackLast->{object}->tokenClose($charStackLast->{chunk}));
  
            $charTokenNestingBest--
              if ref $charStackLast->{object} eq $charClassBest;
            }
          }
        }
      }

    $self->addUnparsed($chunk)
      if length $chunk;
    }


  ###########################################################
  #
  #  addUnparsed $chunk
  #
  #  Adds the given text chunk to the result accumulator
  #  without any further parsing.
  #
  
  sub addUnparsed {
  
    my $self = shift;
    my $chunk = shift;

    my $charStack;

    $charStack = $self->{charStack};

    return $charStack->[-1]{chunk} .= $chunk
      if @$charStack;
    
    $self->{result} .= $chunk;
    }


  ###########################################################
  #
  #  findSeparator $chunk
  #
  #  Looks for class-specific token separators in the given
  #  text chunk and returns a list with its offset and
  #  length, or an empty list if no separator was found or
  #  none is used by this Paragraph class. If the separator
  #  happens to take precedence over character markup,
  #  addSeparator is called after findSeparator.
  #
  
  sub findSeparator { () }


  ###########################################################
  #
  #  addSeparator
  #
  #  Adds to the result accumulator whatever the separator
  #  found by findSeparator last stands for.
  #
  
  sub addSeparator { }


  ###########################################################
  #
  #  charClose
  #
  #  Closes all currently open character formats.
  #

  sub charClose {
  
    my $self = shift;
    
    my $charStack;
    my $charStackLast;

    $charStack = $self->{charStack};
    
    while (@$charStack) {
      $charStackLast = pop @$charStack;
      $self->addUnparsed($charStackLast->{object}->tokenClose($charStackLast->{chunk}));
      }
    }


  ###########################################################
  #
  #  result
  #
  #  Returns the formatted content of the result accumulator
  #  plus any additional markup needed. Called after the
  #  last chunk has been added.
  #
  
  sub result {
  
    my $self = shift;
    
    my $blockStart;
    my $blockEnd;
    my $paraStart;
    my $paraEnd;
    
    $self->charClose();
    
    $blockStart = $self->propBlockStart() if $self->{blockStart};
    $blockEnd   = $self->propBlockEnd()   if $self->{blockEnd};

    $paraStart  = $self->propParaStart()  if defined $self->{result};
    $paraEnd    = $self->propParaEnd()    if defined $self->{result};
    
    $self->cleanup();
    
    return (defined $blockStart     ? $blockStart     : '')
         . (defined $paraStart      ? $paraStart      : '')
         . (defined $self->{result} ? $self->{result} : '')
         . (defined $paraEnd        ? $paraEnd        : '')
         . (defined $blockEnd       ? $blockEnd       : '');
    }


  ###########################################################
  #
  #  cleanup
  #
  #  Releases all references to objects created during the
  #  lifetime of this object and thus readies it for being
  #  automatically destroyed by the Perl interpreter.
  #

  sub cleanup {
  
    my $self = shift;
  
    delete $self->{charObject};
    delete $self->{charStack};
    }
}


###############################################################################
#
#  class ParagraphDefault
#

{
  package ParagraphDefault;


  ###########################################################
  #
  #  Static
  #

  our @ISA = Paragraph;

  sub propParaStart { '<p>'  }
  sub propParaEnd   { '</p>' }
}


###############################################################################
#
#  class ParagraphHeading
#

{
  package ParagraphHeading;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propParaStart   { '<h'  . shift->{headingLevel} . '>' }
  sub propParaEnd     { '</h' . shift->{headingLevel} . '>' }
  sub propParaContent { INLINE }

  ParagraphHeading->register();


  ###########################################################
  #
  #  markupParse  $chunk, [$owner]
  #  markupParse \$chunk, [$owner]
  #
  
  sub markupParse {

    my $class = shift;  $class = (ref $class or $class);
    my $chunk = shift;
    my $owner = shift;
    
    my $self;
    my $chunkref;
    my $headingMarkup;
    
    $chunkref = (ref $chunk ? $chunk : \$chunk);
    $$chunkref =~ s/^(==+|--+)\s*//
      or return undef;
    $headingMarkup = $1;

    $self = $class->new($owner);
    $self->{headingLevel} = (length $headingMarkup > 6 ? 6 : length $headingMarkup);
    $self->{headingType}  = substr $headingMarkup, 0, 1;
    
    return $self;
    }


  ###########################################################
  #
  #  addParsed $chunk
  #
  
  sub addParsed {
  
    my $self = shift;
    my $chunk = shift;
    
    my $chunkBuffer;
    
    $self->{headingNumbered} = $chunk =~ s/#\s*//
      unless defined $self->{headingNumbered};
    
    $chunkBuffer = $self->{chunkBuffer};
    undef $self->{chunkBuffer};
    
    $self->SUPER::addParsed($chunkBuffer)
      if defined $chunkBuffer;
    
    $self->{chunkBuffer} = $chunk;
    }


  ###########################################################
  #
  #  addUnparsed $chunk
  #
  
  sub addUnparsed {
  
    my $self = shift;
    my $chunk = shift;
    
    my $chunkBuffer;
    
    $chunkBuffer = $self->{chunkBuffer};
    undef $self->{chunkBuffer};
    
    $self->SUPER::addParsed($chunkBuffer)
      if defined $chunkBuffer;
    
    $self->SUPER::addUnparsed($chunk);
    }


  ###########################################################
  #
  #  result
  #
  
  sub result {
  
    my $self = shift;

    my $chunkBuffer;
    my $headingLevel;
    my $headingLevelReal;
    my $headingLevelDisplay;
    my $numberingReal;
    my $numberingRealText;
    my $numberingDisplay;
    my $numberingDisplayText;

    $chunkBuffer = $self->{chunkBuffer};
    undef $self->{chunkBuffer};

    $chunkBuffer =~ s/\s*(?:=+|-+)$//;
    $self->SUPER::addParsed($chunkBuffer);

    if (defined $self->{result}) {
      $self->{owner}->info('heading') = { numbering => { display => [], real => [] }, list => [] }
        unless $self->{owner}->info('heading');

      if ($self->{headingNumbered}) {
        $numberingDisplay = $self->{owner}->info('heading' => 'numbering' => 'display');

        $headingLevel = $self->{headingLevel} - 1;
        $numberingDisplay->[$headingLevel]++;
        $numberingDisplay->[$headingLevel] = undef
          while ++$headingLevel < 6;
        $numberingDisplayText = join '.', grep defined, @$numberingDisplay[0..$self->{headingLevel} - 1];
        }

      $numberingReal = $self->{owner}->info('heading' => 'numbering' => 'real');

      $headingLevel = $self->{headingLevel} - 1;
      $numberingReal->[$headingLevel]++;
      $numberingReal->[$headingLevel] = undef
        while ++$headingLevel < 6;
      $numberingRealText = join '.', map $_ || 0, @$numberingReal[0..$self->{headingLevel} - 1];

      $headingLevelReal    = $self->{headingLevel};
      $headingLevelDisplay = grep defined, @$numberingReal;

      push @{$self->{owner}->info('heading' => 'list')}, {
        heading   => $self->{result},
        level     => { real => $headingLevelReal,  display => $headingLevelDisplay  },
        numbering => { real => $numberingRealText, display => $numberingDisplayText },
        };

      $self->{result} = $numberingDisplayText . '&nbsp;&nbsp;' . $self->{result}
        if defined $numberingDisplay;
      $self->{result} = qq[<a name="$numberingRealText"></a>$self->{result}];

      return $self->SUPER::result();
      }

    return '<hr class="thin">' if $self->{headingType} eq '-';
    return '<hr class="thick">';
    }
}


###############################################################################
#
#  class ParagraphIndented
#

{
  package ParagraphIndented;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propParaStart   { '<p class="indent' . shift->{level} . '">' }
  sub propParaEnd     { '</p>' }
  sub propParaContent { INLINE }

  ParagraphIndented->register();


  ###########################################################
  #
  #  markupParse  $chunk, [$owner]
  #  markupParse \$chunk, [$owner]
  #
  
  sub markupParse {

    my $class = shift;  $class = (ref $class or $class);
    my $chunk = shift;
    my $owner = shift;
    
    my $self;
    my $chunkref;
    
    $chunkref = (ref $chunk ? $chunk : \$chunk);
    $$chunkref =~ s/^(:+)\s*//
      or return undef;
    
    $self = $class->new($owner);
    $self->{level} = (length $1 > 6 ? 6 : length $1);
    
    return $self;
    }
}


###############################################################################
#
#  class ParagraphVerbatim
#

{
  package ParagraphVerbatim;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propBlockStart  { '<pre class="paraverbatim">' }
  sub propBlockEnd    { '</pre>' }
  sub propParaStart   { shift->{blockStart} ? undef : "\n" }
  sub propParaEnd     { undef    }
  sub propParaContent { INLINE   }

  ParagraphVerbatim->register();


  ###########################################################
  #
  #  markupParse  $chunk, [$owner]
  #  markupParse \$chunk, [$owner]
  #
  
  sub markupParse {
  
    my $class = shift;  $class = (ref $class or $class);
    my $chunk = shift;
    my $owner = shift;
    
    my $chunkref;
    
    $chunkref = (ref $chunk ? $chunk : \$chunk);
    $$chunkref =~ /^\s/
      or return undef;

    return $class->new($owner);
    }
}


###############################################################################
#
#  class ParagraphBullet
#

{
  package ParagraphBullet;
  
  
  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propMarkup      { '*'     }
  sub propBlockStart  { '<ul>'  }
  sub propBlockEnd    { '</ul>' }
  sub propParaStart   { '<li>'  }
  sub propParaEnd     { '</li>' }
  sub propParaContent { BLOCK   }
  
  ParagraphBullet->register();
}


###############################################################################
#
#  class ParagraphNumber
#

{
  package ParagraphNumber;
  
  
  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propMarkup      { '#'     }
  sub propBlockStart  { '<ol>'  }
  sub propBlockEnd    { '</ol>' }
  sub propParaStart   { '<li>'  }
  sub propParaEnd     { '</li>' }
  sub propParaContent { BLOCK   }
  
  ParagraphNumber->register();
}


###############################################################################
#
#  class ParagraphDefinition
#

{
  package ParagraphDefinition;
  
  
  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propMarkup      { ';'     }
  sub propBlockStart  { '<dl>'  }
  sub propBlockEnd    { '</dl>' }
  sub propParaStart   { '<dt>'  }
  sub propParaContent { BLOCK   }
  sub propParaEnd     { shift->{haveDefinition} ? '</dd>' : '</dt>' }
  
  sub TRUE  () { 1 }
  sub FALSE () { 0 }
  
  ParagraphDefinition->register();


  ###########################################################
  #
  #  findSeparator $chunk
  #
  
  sub findSeparator {
  
    my $self = shift;
    my $chunk = shift;
    
    return ()
      if $self->{haveDefinition};
    
    $chunk =~ /\s*:\s*/
      or return ();
    
    return ($-[0], $+[0] - $-[0]);
    }


  ###########################################################
  #
  #  addSeparator
  #
  
  sub addSeparator {
  
    my $self = shift;
    
    $self->{haveDefinition} = TRUE;
    $self->addUnparsed('</dt><dd>');
    }
}


###############################################################################
#
#  class ParagraphTable
#

{
  package ParagraphTable;
  
  
  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Paragraph;
  
  sub propBlockStart  { '<table class="paratable' . (shift->{columnPending} ? '-border' : '') . '" border=0 cellspacing=0 cellpadding=0>' }
  sub propBlockEnd    { '</table>' }
  sub propParaStart   { '<tr valign=top>' }
  sub propParaEnd     { '</tr>' }
  sub propParaContent { BLOCK   }
  sub propNested      { ()      }
  
  sub TRUE  () { 1 }
  sub FALSE () { 0 }
  
  ParagraphTable->register();


  ###########################################################
  #
  #  markupParse  $chunk, [$owner]
  #  markupParse \$chunk, [$owner]
  #
  
  sub markupParse {
  
    my $class = shift;  $class = (ref $class or $class);
    my $chunk = shift;
    my $owner = shift;
    
    my $self;
    my $chunkref;
    
    $chunkref = (ref $chunk ? $chunk : \$chunk);
    $$chunkref =~ s/^(\|+)([<^>]?)\s*//
      or return undef;

    $self = $class->new($owner);
    $self->columnOpen($2, length $1);

    return $self;
    }


  ###########################################################
  #
  #  findSeparator $chunk
  #
  
  sub findSeparator {
  
    my $self = shift;
    my $chunk = shift;
    
    my $indexPending;
    
    $chunk =~ /\s*(\|+)([<^>]?)\s*/
      or return ();
    
    $indexPending = ($self->{columnPending} ? 1 : 0);
    
    $self->{columnPendingStyle}[$indexPending]{span}  = length $1;
    $self->{columnPendingStyle}[$indexPending]{align} =        $2;
    
    return ($-[0], $+[0] - $-[0]);
    }


  ###########################################################
  #
  #  addSeparator
  #
  
  sub addSeparator {
  
    shift->{columnPending} = TRUE;
    }


  ###########################################################
  #
  #  addUnparsed $chunk
  #
  
  sub addUnparsed {
  
    my $self = shift;
    my $chunk = shift;
    
    my $columnPendingStyle;
    
    if ($self->{columnPending}) {
      $self->columnClose()
        if $self->{columnOpen};
      
      $columnPendingStyle = $self->{columnPendingStyle};
      
      $self->columnOpen($columnPendingStyle->[0]{align},
                        $columnPendingStyle->[0]{span});
  
      shift @$columnPendingStyle;
      $self->{columnPending} = FALSE;
      }

    $self->SUPER::addUnparsed($chunk);
    }


  ###########################################################
  #
  #  columnOpen [$align], [$span]
  #
  #  Opens a new table column, closing the previous one,
  #  spanning the given number of colums, and using the given
  #  text alignment.
  #
  
  sub columnOpen {
  
    my $self = shift;
    my $align = shift;
    my $span = shift;
    
    $align = '<'
      unless defined $align;
    
       if ($align eq '>') { $align = 'right'  }
    elsif ($align eq '^') { $align = 'center' }
    else                  { $align = 'left'   }

    $self->SUPER::addUnparsed('<td'
                            . ($align ne 'left'            ? " align=$align"  : '')
                            . (defined $span and $span > 1 ? " colspan=$span" : '')
                            . '>');

    $self->{columnOpen} = TRUE;
    }


  ###########################################################
  # 
  #  columnClose
  #
  #  Closes a column.
  #
  
  sub columnClose {
  
    my $self = shift;
    
    $self->charClose();
    $self->SUPER::addUnparsed('</td>');

    $self->{columnOpen} = FALSE;
    }


  ###########################################################
  #
  #  result
  #
  
  sub result {
  
    my $self = shift;
    
    $self->columnClose()
      if $self->{columnOpen};
    
    return $self->SUPER::result();
    }
}


###############################################################################
#
#  Character
#
#  Base class for character markup in paragraph classes derived from Paragraph.
#  Character markup is supposed to be started by a start token and ended by an
#  end token; subclasses are free in what they consider to be those tokens. As
#  an object of each registered Character class is kept in memory during text
#  processing and all of those objects are repeatedly queried for their
#  respective opinions, try not to create a separate class for each minimal
#  variation of a markup; better try to actually create character markup
#  classes that handle a whole range of character markup.
#

{
  package Character;


  ###########################################################
  #
  #  Static
  #
  
  our @registered;

  sub propNested { @registered }


  ###########################################################
  #
  #  register
  #
  #  Registers this character markup class for use. Unless
  #  overridden by a specific subclass, all registered
  #  character classes can be nested within each other in
  #  paragraphs with Wiki formatting.
  #
  
  sub register {
  
    my $class = shift;  $class = (ref $class or $class);

    push @registered, $class
      if $class->isa(Character)
      and not grep /^\Q$class\E$/, @registered;
    }


  ###########################################################
  #
  #  new [$owner]
  #
  #  Creates a new Character object, initializes its
  #  variables and returns a reference to it. Inheritable.
  #
  
  sub new {
  
    my $class = shift;  $class = (ref $class or $class);
    my $owner = shift;
    
    my $self;
    
    $self->{owner}      = $owner;
    $self->{tokenType}  = undef;
    $self->{tokenStack} = [];
    
    return bless $self, $class;
    }
  
  
  ###########################################################
  #
  #  tokenFind $text
  #
  #  Returns an empty list if no markup token was found in
  #  the given text or three-element list otherwise: The
  #  first two elements specify the character offset and
  #  the length of the token found. The third element is
  #  either undefined if the found token is the start of
  #  markup that needs to be processed when the end token is
  #  found, or an integer denoting the number of markup
  #  levels of this class that are closed by this token. If
  #  zero is given (rather than undef), tokenProcess will
  #  be called with an empty string.
  #
  
  sub tokenFind { () }


  ###########################################################
  #
  #  tokenOpen
  #
  #  Called when the last token found by tokenFind should be
  #  added to the token stack; more precisely, when the
  #  nesting count returned by tokenFind was either not
  #  defined (opening token of a pair) or zero (singleton
  #  token).
  #
  
  sub tokenOpen { 
  
    my $self = shift;
    
    push @{$self->{tokenStack}}, $self->{tokenType};
    }


  ###########################################################
  #
  #  tokenClose $chunk
  #
  #  Returns the formatted representation of the given text
  #  chunk according to the topmost token on this object's 
  #  token stack. The text chunk itself must remain unparsed.
  #  tokenClose is guaranteed to be called exactly once per
  #  call of tokenOpen.
  #
  
  sub tokenClose { 
  
    my $self = shift;
    my $chunk = shift;

    pop @{$self->{tokenStack}};

    return $chunk;
    }
}


###############################################################################
#
#  CharacterWiki
#
#  Wiki-style character markup.
#

{
  package CharacterWiki;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Character;  
  
  our %formatStart;
  our %formatEnd;
  our $formatPattern;
  
  CharacterWiki->register();


  ###########################################################
  #
  #  Formats
  #
  
  CharacterWiki->registerFormat("''''", "''''", '<em class="em3">%text%</em>');
  CharacterWiki->registerFormat("'''",  "'''",  '<em class="em2">%text%</em>');
  CharacterWiki->registerFormat("''",   "''",   '<em class="em1">%text%</em>');


  ###########################################################
  #
  #  registerFormat $tokenStart, $tokenEnd, $replacement
  #
  #  Registers a new Wiki character markup. Start and end
  #  tokens are arbitary constant character strings (no
  #  regular expressions). The replacement can either be a
  #  string where %text% is replaced by the formatted text
  #  chunk or a code reference that gets the text as its
  #  first argument.
  #
  
  sub registerFormat {
  
    my $class = shift;  $class = (ref $class or $class);
    my $tokenStart = shift;
    my $tokenEnd = shift;
    my $replacement = shift;
    
    $formatStart{$tokenStart}{tokenStart}  = $tokenStart;
    $formatStart{$tokenStart}{tokenEnd}    = $tokenEnd;
    $formatStart{$tokenStart}{replacement} = $replacement;

    $formatEnd{$tokenEnd} = $formatStart{$tokenStart};
    }


  ###########################################################
  #
  #  tokenFind $text
  #
  
  sub tokenFind {
  
    my $self = shift;
    my $text = shift;
    
    my $tokenOffset;
    my $tokenType;
    my $tokenStackCount;
    my $tokenStackItem;
    
    $formatPattern = join '|', map quotemeta, sort { length $b <=> length $a } keys %formatStart, keys %formatEnd
      unless $formatPattern;
    
    do {
      $text =~ /($formatPattern)/go
        or return ();
      
      $tokenOffset = $-[0];
      $tokenType = $1;
      $tokenStackCount = 1;

      foreach $tokenStackItem (reverse @{$self->{tokenStack}}) {
        return ($tokenOffset, length $tokenType, $tokenStackCount)
          if $formatStart{$tokenStackItem}{tokenEnd} eq $tokenType;
        $tokenStackCount++;
        }
      } until $formatStart{$tokenType};
    
    $self->{tokenType} = $tokenType;
    
    return ($tokenOffset, length $tokenType);
    }


  ###########################################################
  #
  #  tokenClose $chunk
  #
  
  sub tokenClose {
  
    my $self = shift;
    my $chunk = shift;
    
    my $replacement;

    $chunk = ''
      unless defined $chunk;

    $replacement = $formatStart{pop @{$self->{tokenStack}}}{replacement};
    
    return &$replacement($chunk)
      if ref $replacement eq CODE;
    
    $replacement =~ s/%text%/$chunk/g;
    return $replacement;
    }
}


###############################################################################
#
#  CharacterHtml
#
#  Escapes characters relevant to HTML, skipping HTML entities and protected
#  tags in the process.
#

{
  package CharacterHtml;
  

  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Character;
  
  our @htmlSingle = qw(br hr img);
  our @htmlPair   = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
                       em s strike strong tt var div center blockquote ol ul dl
                       table tr td th dt dd li caption);
  
  our %htmlSubst = (
    "\n"    => '<br>',
    '--'    => '&ndash;',
    '---'   => '&mdash;',
    '----'  => '&mdash;',
    '->'    => '&rarr;',
    );
  
  our $patternHtml;
  our $patternSubst;
  our %htmlSingle;
  our %htmlPair;

  sub TRUE  () { 1 }
  sub FALSE () { 0 }

  CharacterHtml->register();


  ###########################################################
  #
  #  Initialization
  #
  
  INIT {
  
    $patternHtml  = join '|', map quotemeta, @htmlSingle, @htmlPair;
    $patternSubst = join '|', map quotemeta, sort { length $b <=> length $a } keys %htmlSubst;
  
    %htmlSingle = map { $_ => TRUE } @htmlSingle;
    %htmlPair   = map { $_ => TRUE } @htmlPair;
    }


  ###########################################################
  #
  #  tokenFind $text
  #
  
  sub tokenFind {
  
    my $self = shift;
    my $text = shift;
    
    my $tagOpen;
    my $tagClose;
    my $tokenLength;
    my $tokenNesting;
    my $tokenOffset;
    my $tokenStack;
    my $type;
    
    $tokenStack = $self->{tokenStack};
    
    undef $self->{tokenType};

    for (;;) {
      $text =~ m[(<) (?= (/?) ($patternHtml) \b ([^>]*) > )? |
                 (>)                                         |
                 (&) (?! [A-Za-z][a-z]+; | \#\d+; )          |
                 ($patternSubst)                             ]goxi
        or return ();

      $tokenOffset = $-[0];
      $tokenLength = $+[0] - $tokenOffset;

      if ($1) {
        if (not defined $2) {
          $self->{tokenType}{replacement} = '&lt;';
          return ($tokenOffset, $tokenLength, 0);
          }
      
        if ($2) {
          $type = lc $3;
        
          $tokenNesting = 1;
          $tokenNesting++
            while $tokenNesting <= @$tokenStack
            and $tokenStack->[-$tokenNesting]{type} ne $type;
          
          if ($tokenNesting > @$tokenStack) {
            $self->{tokenType}{replacement} = '';
            return ($tokenOffset, (length $3) + (length $4) + 3, 0);
            }

          $tagClose = "</$3$4>";
          $tokenStack->[-$tokenNesting]{tagClose} = $tagClose;

          return ($tokenOffset, length $tagClose, $tokenNesting);
          }
        
        elsif ($htmlSingle{lc $3}) {
          $tagOpen = "<$3$4>";
          $self->{tokenType}{replacement} = $tagOpen;

          return ($tokenOffset, length $tagOpen, 0);
          }

        else {
          $tagOpen  = "<$3$4>";
          $tagClose = "</$3>";
        
          $self->{tokenType}{type}     = lc $3;
          $self->{tokenType}{tagOpen}  = $tagOpen;
          $self->{tokenType}{tagClose} = $tagClose;
          
          return ($tokenOffset, length $tagOpen);
          }
        }

      else {
           if (defined $5) { $self->{tokenType}{replacement} = '&gt;'         }
        elsif (defined $6) { $self->{tokenType}{replacement} = '&amp;'        }
        elsif (defined $7) { $self->{tokenType}{replacement} = $htmlSubst{$7} }

        return ($tokenOffset, $tokenLength, 0);
        }
      }

    return ();
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
    
    return $tokenType->{replacement}
      if defined $tokenType->{replacement};
    
    $chunk = ''
      unless defined $chunk;
    
    return $tokenType->{tagOpen} . $chunk . $tokenType->{tagClose};
    }    
}


###############################################################################
#
#  CharacterLink
#
#  External links and links to Wiki pages, both implicit and explicit. Also
#  handles image links.
#

{
  package CharacterLink;


  ###########################################################
  #
  #  Static
  #
  
  our @ISA = Character;  
  
  our $countLinks       = 0;
  our $patternAddress   = '[^]\s]*[\w/]';
  our $patternMail      = '[-\w.]+@[-\w.]+\.\w+';
  our $patternProtocols = '(?i)(?:http|https|ftp|afs|news|mid|cid|nntp|mailto|wais|irc):';

  our $typePattern;
  our %typeReplacement;
  
  CharacterLink->register();


  ###########################################################
  #
  #  Types
  #

  CharacterLink->registerType('gif',  '<img src="%url%">');
  CharacterLink->registerType('jpg',  '<img src="%url%">');
  CharacterLink->registerType('jpeg', '<img src="%url%">');
  CharacterLink->registerType('png',  '<img src="%url%">');


  ###########################################################
  #
  #  registerType $extension, $replacement
  #
  #  Registers a file type by extension for special handling,
  #  for instance for rendering as an embedded image rather
  #  than a clickable link. The given replacement can either
  #  be a string where %url% is replaced by the parsed URL
  #  or a code reference that gets the URL as its first
  #  argument.
  #

  sub registerType {
  
    my $class = shift;  $class = (ref $class or $class);
    my $extension = shift;
    my $replacement = shift;
    
    $typeReplacement{lc $extension} = $replacement;
    }


  ###########################################################
  #
  #  tokenFind $text
  #
  
  sub tokenFind {
  
    my $self = shift;
    my $text = shift;
    
    my $tokenLength;
    my $tokenOffset;
    my $tokenStack;
    my $tokenType;
    my $tokenNesting;
    
    $tokenStack = $self->{tokenStack};
    
    if (@$tokenStack) {
      for ($tokenStack->[-1]{type}) {
        /PAGE/ and do { $text =~ /\]\]/ and return ($-[0], 2, 1) or return () };
        /URL/  and do { $text =~   /\]/ and return ($-[0], 1, 1) or return () };
        }
      }

    $text =~ /\[   ($patternProtocols $patternAddress) \s* |
              \[\[ ([^]|]+) \s* (?:\|\s*)?                 |
                   ($patternMail)                          |
                   ($patternProtocols $patternAddress)     /ox
      or return ();
    
    $tokenOffset = $-[0];
    $tokenLength = $+[0] - $tokenOffset;
    
    return ()
      unless defined $tokenOffset;

       if ($1) { $tokenType->{type} = URL;   $tokenType->{url}  = $1 }
    elsif ($2) { $tokenType->{type} = PAGE;  $tokenType->{page} = $2 }
    elsif ($3) { $tokenType->{type} = MAIL;  $tokenType->{mail} = $3;  $tokenNesting = 0 }
    elsif ($4) { $tokenType->{type} = URL;   $tokenType->{url}  = $4;  $tokenNesting = 0 }

    $self->{tokenType} = $tokenType;

    return ($tokenOffset, $tokenLength, $tokenNesting);
    }


  ###########################################################
  #
  #  tokenClose $chunk
  #
  
  sub tokenClose {
  
    my $self = shift;
    my $chunk = shift;
    
    my $page;
    my $replacement;
    my $tokenType;
    
    $tokenType = pop @{$self->{tokenStack}};
    
    for ($tokenType->{type}) {

      #################################
      #
      #  External
      #

      /URL/ and do {
        $typePattern = join '|', map quotemeta, keys %typeReplacement
          unless $typePattern;
      
        if ($tokenType->{url} =~ /($typePattern)$/io) {
          $replacement = $typeReplacement{lc $1};
          
          return &$replacement($tokenType->{url}, $chunk)
            if ref $replacement eq CODE;
            
          $replacement =~ s[\%url\%]  [$tokenType->{url}]g;
          $replacement =~ s[\%text\%] [defined $chunk ? $chunk : '']ge;

          return $replacement;
          }

           if (not defined $chunk) { $chunk = $tokenType->{url} }
        elsif (not length  $chunk) { $chunk = '[' . ++$countLinks . ']' }
        else                       { $chunk = '[' .   $chunk      . ']' }
        
        $self->{owner}->{owner}->info('link' => 'url' => $tokenType->{url})++
          if $self->{owner}->{owner};
        
        return qq[<a href="$tokenType->{url}">$chunk</a>];
        };
      
      
      #################################
      #
      #  Internal
      #
      
      /PAGE/ and do {
        $chunk = $tokenType->{page}
          unless defined $chunk and length $chunk;
      
        $page = $tokenType->{page};
        $page =~ s[^/] [$UseModWiki::MainPage/]
          if defined $UseModWiki::MainPage;
        $page = &UseModWiki::FreeToNormal($page)
          if defined &UseModWiki::FreeToNormal;
      
        $self->{owner}->{owner}->info('link' => 'page' => $page)++
          if $self->{owner}->{owner};

        return UseModWiki::GetPageOrEditLink($tokenType->{page}, $chunk)
          if defined &UseModWiki::GetPageOrEditLink;
        
        return qq[<a href="/wiki/$tokenType->{page}">$chunk</a>];
        };
      

      #################################
      #
      #  Mail
      #

      /MAIL/ and do {
        $self->{owner}->{owner}->info('link' => 'mail' => lc $tokenType->{mail})++
          if $self->{owner}->{owner};

        return qq[<a href="mailto:$tokenType->{mail}">$tokenType->{mail}</a>];
        };
      }
      
    return undef;
    }
}
