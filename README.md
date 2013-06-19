opt2env
======

opt2env -- parse command line options and set environment variables based on this options  
You don't need to parse your options manually -- just write optstring and call opt2env function

### Usage
Paste code from opt2env.sh at the beginning of your bash script and call opt2env function with the following options:  
`opt2env "$USAGE" "$OPTSTRING" "$@"`  
where **OPTSTRING** is the string with description of options:  
`"[-f|--foo|...|{FOO} <argument> example of option][-b|--bar|...|{BAR} another one]..."`  
Here *-f, -foo* is example of an option that requires argument. After call of opt2env environment variable FOO will be set to user's value.
*-b, --bar* is example of an option that doesn't require argument. If it's encountered among command line an options, environment varialbe BAR will be set to 1.  
"$USAGE" is the brief description of what your script do; can be empty string.
Free arguments are stored in the **FREE_ARGUMENTS** array.

If invalid command line options are passed opt2env will notify user and terminate execution.

*Note that opt2arg doesn't support options style when argument is passed without space, e.g. -n100 instead of -n 100.*

You can echo help based on your OPTSTRING and USAGE. To do this call  
`echo_help "$USAGE" "$OPTSTRING"`  

### Examples
1.
```bash    
usage="demo script"
docstring="[-b|{BAR} its a bar!][-f|--foo|{FOO} <filename> description of this option]"
echo_help "$usage" "$docstring"
```
will result in

    demo script 

        -b its a bar!
        -f|--foo <filename> description of this option
        -h|--help print help
    
2.
```bash
usage="demo script"
docstring="[-b|{BAR} its a bar!][-f|--foo|{FOO} <filename> description of this option]"
opt2env "$usage" "$docstring" "$@"
echo $FOO
echo $BAR
set -- "${FREE_ARGUMENTS[@]}" # set free arguments to positional parameters
echo $1
echo $2
```

will result in

    ./demo.sh "one cow" -f Fee -b two
    Fee
    1
    one cow
    two
    
Note, that in example above `-f <filename>` or `--foo <filename>` is parametrised argument, so env. variable FOO is set to "Fee". And `-b` or `--bar` is switch, so env. varialbe BAR is set to 1, when "two" and "one cow" are free arguments and can be accessed through FREE_ARGUMENTS array. Using *set* command we've set this free arguments to positional parameters, so they can be accessed though variables $1 and $2.

