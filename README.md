# Untypo
Help recover passwords / etc. that were incorrectly entered with a typo

## Detailed Summary
There are many times (password changes, etc.) where you go back to enter your new password and it just does not work. Often, it's something simple - you dropped a character, doubled a character, or typed the whole thing with cAPS lOCK oN.

Untypo lets you generate a word list of possible typos, so that you can then apply automation to try them all.

## Supported Typo Recovery Options

### Per-character transformations
- Forgot to type a character
- Double a character
- Typed a phsically adjacent character 

### Global transformations
- Accidentally engaged CAPS at some point
- Password was held in a .NET System.SecureString, was saved via .ToString()
- Spaces got added to the beginning or end (i.e. through pasting)
- Had an alternate keyboard layout engaged
