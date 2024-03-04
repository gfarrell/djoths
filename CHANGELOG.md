# Revision history for djot

## 0.1.1.1 -- 2024-03-03

* Revert "Djot.Blocks: use ByteString directly in `toIdentifier` (#1)"
  This caused problems for UTF-8 sequences that contained the
  byte 0xa0, which B8.words treats as a space character.

* AST: avoid using B8.words in normalizeLabel.

* Avoid using isSpace in attribute parsing. isSpace matches a byte 0x0a,
  which can break up a UTF-8 sequence. Limit to ASCII whitespace.

  * Add test with UTF-8 identifier. See jgm/pandoc#9541.

## 0.1.1.0 -- 2024-02-29

* Add Data instances to everything in the AST [API change].

* Ensure that block attributes are indented on subsequent lines (#2).

* Djot.Blocks: use ByteString directly in `toIdentifier` (#1,
  Vaibhav Sagar).

## 0.1.0.0 -- 2024-02-14

* Initial release.

