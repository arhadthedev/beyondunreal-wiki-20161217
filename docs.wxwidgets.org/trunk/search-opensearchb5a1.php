<?xml version="1.0" encoding="UTF-8"?>
<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">
<ShortName>Search wxWidgets</ShortName>
<Description>Doxygen Search</Description>
<InputEncoding>UTF-8</InputEncoding>
<!--
<Image height="16" width="16" type="image/x-icon">
http://dev.squello.com/doc/html/favicon.ico</Image>
-->
<Url type="text/html" method="GET"
template="http://docs.wxwidgets.org/trunk/search.php?query={searchTerms}" />
<Url type="application/x-suggestions+json" method="GET"
template="http://docs.wxwidgets.org/trunk/search-opensearch.php?v=json&amp;query={searchTerms}" />
<Url type="application/x-suggestions+xml" method="GET"
template="http://docs.wxwidgets.org/trunk/search-opensearch.php?v=xml&amp;query={searchTerms}" />
</OpenSearchDescription>