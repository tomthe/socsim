# Supervisory and rate files

The name of the , generally with suffix, is passed to Socsim on the
command line. Socsim expects such a filename followed by a random number
seed and will not run without these two command line arguments.

What Socsim expects to find in the supervisory file is a set of
parameters and possibly rate specifications that allow it to run the
simulation. The supervisory file has to either contain all of the
information Socsim needs (aside from the random number seed) or else it
must have directives that tell Socsim where else to look. The file must
consist entirely of valid directives or comment lines. Comments are
lines that begin with ’\*’. Comments are ignored by Socsim.

The file includes both global (affecting the entire simulation) and
segment specific simulation parameters. The directive indicates the end
of a set of segment specific parameters. When Socsim encounters a
directive, it stops reading the file and executes the simulation
segment. When the segment’s execution is complete, Socsim returns to
reading the file where it left off. This has two important implications:

1.  If the directives for a segment are not followed by a directive, the
    segment will not be executed. Socsim will simply read the
    instructions for the next segment and execute those – assuming that
    they end with a directive.

2.  Errors in a file will not be caught until they are encountered. If
    there is an error in the specification of the \(92^{nd}\) segment,
    Socsim will execute the first 91 segments before it exiting
    abnormally.

## Minimal .sup file

At a minimum the supervisory file must include only a few directives.
Figure [\[fig:supSample\]](#fig:supSample) shows a minimal but
sufficient
    file.

-----

    ************************************************************************
    ** This is the simplest possible socsim .sup file. It will run a one
    ** segment simulation with starting population in test.opop and
    ** test.omar and ending population in test.out{.opop,.omar} The
    ** duration of the one and only "segment" is 1200 months; the minimum
    ** birth interval is 24 months; heterogenous fertility is turned off;
    ** rate files are in ratefile.Lese.
    **
    ** type [path to socsim] run.sup 12345
    ** to run socsim
    ************************************************************************
    segments 1
    input_file test
    output_file test.out
    duration 1200
    
    include ratefile.Lese
    run

-----

## Global Directives

Global directives can affect the entire simulation and *generally* do
not change with each new segment. With the exception of , and , however,
it is possible to change global directives in a simulation segment. What
“global” means is that socsim does **not** reinitialize these directives
to their default settings at the beginning of each simulation segment–as
it does for the “segment specific” directives described in
Section [1.4](#sec:segmentSpecific).

This means that **you can change most global directives within each
simulation segment**. If Socsim finds a global directive such as or
after the first directive, it **will** change its behavior accordingly
and the new behavior will persist until either the end of the simulation
or until the directive is encountered again.

**Be aware** that if you decide to change a global directive for a
particular segent, **the new value becomes the default** for subsequent
simulation segments. In the case of segment specific directives, the
default values are reset at the start of a new segment.

1.  
2.  
3.  
4.  
5.  
6.  
7.  
8.  
9.  
10. 
11. 
12. 
13. 
14. 
15. 
16. 
17. 
18. 
19. ## Directives used in extended versions
    
    A few directives are included for convenience when extending SOCSIM.
    in the plain version of SOCSIM, none of these directives should be
    set.

20. 
21. 
22. 
## Segment specific directives

These directives make sense if specified for each simulation segment.

1.  
2.  
3.  ``` 
      execute generate_rates 1 5 0 >mortality.seg4
      include mortality.seg4
    ```
