# Specifying demographic rates

It is most convenient to store demographic rates for each simulation
segment in distinct files and use the directive to reference them from
the supervisory file (See Section [\[sec:supFile\]](#sec:supFile)). But
regardless of how you choose to organize your rate files, you will need
to assemble a large collection of rates. How Socsim expects those rates
to be formatted is described in Section [1.2](#sec:vitalRates), but
before we get to that Section [1.1](#sec:rateDefault) describes the
rules Socsim follows when it encounters incomplete rate sets. These are
important to understand, because Socsim does not warn you when for
example you leave out fertility rates for parity 1 divorced females of
group 3 (birth 3 F divorced 1). Instead, it “defaults” to rates for
party 0 divorced females of group 3 (birth 3 F divorced 0). Similarly if
the birth 3 F divorced 0 rates are missing, Socsim uses birth 3 F single
0) in their place. The rules are fairly intuitive, but its important to
understand that one can err by not specifying that certain rates are
zero.

## Rate default rules

To run a moderately realistic simulation, Socsim requires age specific
fertility rates for females and mortality rates for both males and
females of each and marital status. If rates do not differ by marital
status or group then you can use Socsim’s default rules to avoid
entering the same blocks of rates repeatedly. When Socsim encounters
incomplete rates sets, it follows a set of rules to determine how the
blanks are to be filled in.
Figure [\[fig:rateDefaults\]](#fig:rateDefaults) shows the rules that
Socsim uses when it encounters incomplete rate sets. The “==\>” symbol
in Figure [\[fig:rateDefaults\]](#fig:rateDefaults) means “defaults to”
so for example,

``` 

widowed                         ==> divorced; parity 0; group 1
```

which appears in the “Fertility Rates” section under the heading “For
parity zero women in group 1” indicates that if Socsim does not find
fertility rates for parity zero, widowed females in group 1 it will
“default to” the rates for divorced women of parity zero and group 1.

Where Figure [\[fig:rateDefaults\]](#fig:rateDefaults) indicates that a
rate block defaults to “Zero”, Socsim does not default to anything
leaving such events with zero probability of occurring at any age. So
for example, unless you think that single males in group 1 should live
forever, you must specify mortality rates for such
“people”.

<span id="fig:rateDefaults" label="fig:rateDefaults">\[fig:rateDefaults\]</span>

  
**Fertility Rates**

``` 
    
For parity zero women in group 1 
--------------------------------
single                          ==> Zero
married                         ==> Zero
divorced                        ==> single; parity 0; group 1
widowed                         ==> divorced; parity 0; group 1
cohabiting                      ==>  married; parity 0; group 1

For women in group 1 with higher parity
------------------------------------------
mstatus m; PARITY P; group 1     ==> mstatus m; PARITY P-1; group 1

For women of any parity and any group > 1

mstatus m; parity  p; GROUP  G   ==>  mstatus m; parity p; GROUP G-1
```

**Marriage, Divorce and Mortality Rates**

``` 

For men and women in group
-----------------------------------
DEATH    for single; sex s; group 1       ==> Zero
MARRIAGE for single; sex s; group 1       ==> Zero
DIVORCE  for mstatus m; sex s; group 1    ==> Zero

  (Events except for divorce)
-----------------------------
event e for divorced;sex s    ==>  event e; for single;sex s;group 1  
event e for widowed;sex s     ==>  event e; for divorced;sex s;group 1  
event e for married;sex s     ==>  event e; for widowed;sex s;group 1  
event e for cohabitting;sex s ==>   event e; for married;sex s;group 1  

For Groups > 1
--------------
event e for mstatus m;sex s; group g ==> event e for mstatus m;sex s; group g-1
```

**Group Transition Rates**

    TRANSITTION to group H for mstatus m;sex s; group g == Zero

  

## Structure of vital rates

The format in which Socsim expects to find rates is simple. Each of
rates begins with a set of keywords which indicate the event for which
the rates apply and the marital status, sex, group membership and
possibly parity of the people who are at risk of experiencing the event.
That information is followed on subsequent lines of rate values and the
**upper bound** of the age group for which the rate is in force.

A is a complete set of age specific rates governing a demographic event
for people of a particular sex,group and marital status. An example of a
rate block is shown in Figure [\[fig:rateBlock\]](#fig:rateBlock). The
first line after the comment line, indicates which event (death); group
(1); sex (M=male); and marital status (single) this rate block pertains
to. The order matters and is always, Event then group then sex then
marital status. In the case of birth rates this may be followed by
number indicating parity. In the case of transition rates, the line must
end with a number indicating the destination group.

Each subsequent line contains a one month rate (in the case of
fertility) or a one month probability in the case of all other events,
and the age interval over which the monthly rate (probability) holds.
The first two numbers in the line are years and months of the upper age
bound. These are added together so a 1 and 11 would mean 23 months. The
third number is the rate. In the case of fertility it represents the
expected number of births **per month** to a woman who survives to end
of the given age interval. Specifically – The interval that includes
upper age bound given in the previous line and ends just before the
upper age bound given on the **current line**.

Figure [\[fig:rateBlock\]](#fig:rateBlock) shows an example of rate
block. The first line indicates that that rates which follow refer to
mortality of group 1 single males (death 1 M single).

The first first rate line (`0 1 .0460940`) indicates that the
probability of death in the first month of life for males (technically
for never married males) is .0460940. Note that a rate line with an
upper age bound of “0 0” is meaningless and is ignored. So be careful
when specifying infant mortality rates.

Taking another line from Figure [\[fig:rateBlock\]](#fig:rateBlock), the
probability that a single male dies between the ages of 1141 and 1200
months, conditional on having survived to the beginning of the age
interval is \(1-(1-.08326)^{60}\).

<span id="fig:rateBlock" label="fig:rateBlock">\[fig:rateBlock\]</span>

    *Mortality, single Male (lines beginning with * are comments)
    death 1 M single
    0       1       .0460940
    0       12      .0057540
    0       60      .0008730
    0       120     .0002600
    .
    .
    .
    0       1140    .0832630
    0       1200    .0832630

## Mortality rates

Mortality rates are the most straight forward of the rates that Socsim
uses. The example in Figure [\[fig:rateBlock\]](#fig:rateBlock) is
typical. The event identifier is , the “1” refers to the group, “M” to
male and “single” is of course marital status.

## Marriage rates

Marriage rates are specified with the event identifier of , but it
should be born in mind the event which these rates regulate is not
really marriage but rather the commencement of a marriage search. Since
marriage requires two participants Socsim cannot simply execute a
marriage when the event is scheduled. Marriage requires two participants
and such it is very difficult to achieve arbitrarily specified marriage
rates for both males and females. If a marriage age distribution is also
part of the simulation, it gets even harder. Socsim deals with this in a
variety of ways which are described in
Section [\[sec:marriageQueue\]](#sec:marriageQueue) and
Section [\[sec:supFile\]](#sec:supFile).

As a consequence, of all this excuse making is that marriage rates often
need to be “tuned” in order to achieve the desired result.

## Divorce rates

Divorce rates are specified with the event identifier . Divorce is
unusual among Socsim events in that it’s rates do not apply to the age
of one spouse or the other but rather by age of the marriage. It is thus
generally not necessary to specify divorce rates for both sexes.

## Fertility rates

Fertility rates are specified with the identifier and are different from
other rates in two ways:

1.  They are parity specific. But they default to parity \(n-1\) so it
    is only necessary to specify rates for parity zero.

2.  They are rates rather than probabilities. So multiplying a rate by
    the number of months in the age category gives the expected number
    of births that a woman who lives through the age category will
    experience.

## Transition rates

Transition rates give rates of “transition” from one to another. By
default, no transitions occur, however, if the initial population
contains more than one group then the group inheritance rule determines
the group identity of new borns.

Transition rates are specified with the identifier and are different
from other rates in that both the group to which the rate applies
**and** the group to which the event will cause a person to belong must
be specified.

To specify transition rates from group 1 to group 2 for single males,
one would write the following:  
  
trasit 1 M single 2  
  
As noted in Figure [\[fig:rateDefaults\]](#fig:rateDefaults), transition
rates have no defaults. All rates have to be specified in order to take
effect.

### Duration specific transition rates

It is often useful for transition rates to be duration rather than age
specific. In other words, the probability of a transition event
occurring can depend on the time since the individual transitioned into
the current group rather than the individual’s age. In order for this
distinction to matter, a person must have experienced at least one
transition other wise the time spent in the group is equivalent to the
person’s age.

Divorce rates are always duration specific, but transition rates may
vary with either age or duration. The format for specifying transition
rate blocks is the same regardless of whether they are age or duration
specific. To tell Socsim that a particular rate block is meant to be
duration specific, add the directive: as in:  
  
duration\_specific transit 4 F married 5  
  
when this directive is encountered, the log file will indicate that
transition rates from group 4 to group 5 for married females will be
duration rather than age specific. The default is for transition rates
to be age specific so no indication is given in the log file of that
condition. It is possible to have both age and duration specific
transition rates in effect in the same simulation, however, only one
transition rate block is allowed per pair of groups. So transitions from
say group 3 to group 5 for single males must be *either* age or duration
specific, but whichever it is, has no effect on transitions from group 3
to group 5 for ***married*** males. One may be age specific while the
other may be duration specific.

As noted in Section [\[sec:segmentSpecific\]](#sec:segmentSpecific), the
directive does not replace the keywords that define the rate block.
