# Population files

Socsim reads and writes everything it knows about people in two files:
the population file and the marriage file\[1\]. Both are space delimited
files and both contain only numbers.

Since one generally runs Socsim for 200 simulated years in order to
start from a population with a known and stable age structure, it is
seldom necessary to construct an initial population with any information
other than the age and sex of a small number of individuals. Such a file
can be easily constructed in a spreadsheet program. The coresponding
marriage file is simply an empty file with correct name.

One needs to come to terms with the structure of the .opop and .omar
files in much more detail when analyzing simulation output. A snipet of
code for reading an .opop file into R is given in
Figure [\[fig:readOpop\]](#fig:readOpop). In terms of R the .opop
file’s contents fit naturally into a with 14 columns all of which are
numerical. In more general terms, the .opop file is a matrix where each
row contains information on a single person and each column contains a
particular bit of infromation on each person.

Although it’s structure suggests that a .opop file might be right at
home in a spreadsheet program, this is not so. First the files tend to
be too large since they include not only a row for each person who ever
lived. Even a modest sized simulation can easily have 100,000 rows. But
more important, much of the information in the .opop file consists of
identification numbers of other people. In other words the opop file is
a multiply linked list. For manipulating linked lists, spreadsheets are
profoundly
    suboptimal.

-----

    ## read .opop into dataframe the .opop file contains one row for each
    ## simulated person who ever "lived". It generally includes many who
    ## "died" long ago.
    
    opop<-read.table(file="../SimResults/example.opop",header=F,as.is=T)
    
    ## assign names to columns
    names(opop)<-c("pid","fem","group",
                   "nev","dob","mom","pop","nesibm","nesibp",
                   "lborn","marid","mstat","dod","fmult")

-----

<span id="fig:readOpop" label="fig:readOpop">\[fig:readOpop\]</span>

In most cases, the .opop file will be sorted in order of person id and
since person ids are sequential integers assigned in birth order this
means that the .opop file is generally sorted in birth order, with the
row number often being the same as the person id. This is not however
guaranteed to be the case so check that it is so before relying on
it\[2\].

Table [\[tab:opop\]](#tab:opop) shows which information is in each
column.

| **position** | **name** | **description**                                                                       |
| -----------: | :------- | :------------------------------------------------------------------------------------ |
|            1 | pid      | Person id unique identifier assigned as integer in birth order                        |
|            2 | fem      | 1 if female 0 if male                                                                 |
|            3 | group    | Group identifier 1..60 current group membership of individual                         |
|            4 | nev      | Next scheduled event                                                                  |
|            5 | dob      | Date of birth integer month number                                                    |
|            6 | mom      | Person id of mother                                                                   |
|            7 | pop      | Person id of father                                                                   |
|            8 | nesibm   | Person id of next eldest sibling through mother                                       |
|            9 | nesibp   | Person id of next eldest sibling through father                                       |
|           10 | lborn    | Person id of last born child                                                          |
|           11 | marid    | Id of marriage in .omar file                                                          |
|           12 | mstat    | Marital status at end of simulation integer 1=single;2=divorced; 3=widowed; 4=married |
|           13 | dod      | Date of death or 0 if alive at end of simulation                                      |
|           14 | fmult    | Fertility multiplier                                                                  |

contents and format of the .opop file<span label="tab:opop"></span>

## Reckoning kinship

In analyzing Socsim output, one is often interested in reckonning
kinship. Since with the possible exception of the initial population,
everyone in socsim is related to everyone else, it is possible to find
nearly any two people’s relationship by following the chain of parents
and siblings. To find ego’s maternal grandmother, one simply finds the
ego’s mother’s person id in the \(6^{th}\) column of ego’s row in the
opop file. Moving then to the row of the opop file coresponding to ego’s
mother’s person id, one look’s again in the \(6^{th}\) column to find
egos’ mother’s mother’s person id.

To find all of ego’s children, one starts with the person id of ego’s
last born child (stored in column 10) of egos’ row of opop. In the row
coresponding to ego’s last born child’s row of opop, we find, in column
8 (9), ego’s last born child’s next eldest sibling through her mother
(father). In that person’s row of the .opop file, we can find yet
another next eldest sibling and so on until we find ego’s first born
child, whose next eldest sibling through mother (assuming that ego is
female) is necessarily zero.

Alternatively, one could simply collect all the rows of opop which have
that same value in column 6 (mom) and or 7(dad) as ego has.

The R computing environment (<http://www.r-project.org>is particularly
well suited for doing this kind of analysis of kinship.

## Reference to marriages

Since individuals can be married more than once (simultaneously in some
cases) reckoning marriage information is trickier than working with
kinship alone. See Section [\[marriageFile\]](#marriageFile) for more
details on how to work with Socsim’s .omar file. For the present purpose
note that column 11 of the .opop file contains a pointer, in the form of
a marriage id number, to ego’s most recent marriage. If column 11 is
zero, then ego has never been married.

## Reference to transition history

If the simulation includes group transitions, than socsim will write a
file with the same path as the population and marriage files but with
the suffix . The transition events do not have unique ids as do
marriages, but each transition record contains the person id of the
protagonist. Consequently it is much more natural to link from the
transition history to the population file.

Section [\[otxFile\]](#otxFile) describes the file in detail.

1.  It may also read and write a file of extra variables and a file of
    transition history

2.  It is best practice not to rely on the .opop file’s pid ordering
    because this convention can be broken in the initial population file
