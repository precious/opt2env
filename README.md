opt2env
======

opt2env -- parse command line options and set environment variables based on this options

You don't need to parse your options manually -- just write opstring and call opt2env function

#### Usage
Paste code from opt2env.sh at the beginning of your shell script and call opt2env function with the following options:
`opt2env "$OPTSTRING" "$@"`
where **OPTSTRING** is string of options 
`"[-f|--foo|...|{FOO} <argument> example of option][-b|--bar|...|{BAR} another one]..."`
Here *-f, -foo* is example of option that requires argument. After call of opt2env environment vaiable FOO will be set user's value.
*-b, --bar* is example of option that doesn't require argument. If it's encountered among command line options, environment varialbe BAR will be set to 1.
On success exit code will be zero, otherwise non-zero.
Free arguments are stored in the **FREE_ARGUMENTS** array.

Also you can echo help based on your OPTSTRING. To do this call
`echo_help "$OPTSTRING"`

#### Examples
1.  ```docstring="[-b|{BAR} its a bar!][-f|--foo|{FOO} <filename> description of this option]"
echo_help "$docstring"
```

  ```
    -b its a bar!
    -f|--foo <filename> description of this option
    -h|--help print help
``` 
    
2. ```docstring="[-b|{BAR} its a bar!][-f|--foo|{FOO} <filename> description of this option]"
opt2env "$docstring" "$@"
echo $? # echo exit status
echo $FOO
echo $BAR
set -- "${FREE_ARGUMENTS[@]}" # set free arguments to positional parameters
echo $1
echo $2
```

  ```./example.com "one cow" -f Fee -b two
0
Fee
1
one cow
two
```

  Here we set environment variables FOO and BAR to "Fee" and 1, then set free arguments to positional parameters.

