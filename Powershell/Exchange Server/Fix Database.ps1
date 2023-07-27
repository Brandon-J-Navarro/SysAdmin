<#
Released under MIT License

Copyright (c) 2023 Brandon J. Navarro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# Exchange Fix Database

eseutil /mh database.edb database health
eseutil /p database.edb "fix"
eseutil /ml E01 logfile health

# C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\[MAILBOXDATABASE]\[MAILBOXDATABASE].edb
# C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\[MAILBOXDATABASE]\[MAILBOXDATABASE].edb
# C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\[MAILBOXDATABASE]\E01
# C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\[MAILBOXDATABASE]\E00
# https://www.stellarinfo.com/blog/resolve-unable-mount-database-hr0x80040115-error/
# https://learn.microsoft.com/en-us/answers/questions/1084430/error-after-exchange-kb5019758-update.html
