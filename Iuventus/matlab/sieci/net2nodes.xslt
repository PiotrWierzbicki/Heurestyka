<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
>
  <xsl:output method="text" indent="yes"/>


<xsl:template match="/">
    <xsl:for-each select="network/networkStructure/nodes/node">
      <xsl:value-of select="concat(coordinates/x, ', ', coordinates/y, ', ',@id,'&#xA;')"/>

    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
