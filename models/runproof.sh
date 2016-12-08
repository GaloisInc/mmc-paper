#!/bin/bash

# set -e -u -x

# BSD License
# Copyright (c) 2008, Lee Pike (Galois, Inc.) leepike [at] galois.com
# Copyright (c) 2015, Benjamin Jones (Galois, Inc.) <bjones@galois.com>
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of the <organization> nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY <copyright holder> ``AS IS'' AND ANY
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# --- USAGE ---
# Takes a SAL file, and runs all the proof commands listed in that file in a
# form such as

# %   sal-smc file.sal property1
# or
# % sal-bmc -i -d 1 fail.sal property2
# etc.

# There can only be one '%' (the comment indicator in SAL) preceding the proof
# directive.  An arbitrary amount of whitespace may follow the '%' before the
# directive.

# Proof commands can be listed anywhere -- say all at the top, the bottom, or
# sitting right next to the corresponding theorems.

# -- USAGE EXAMPLES ---
# runproof.sh --help : help

# runproof.sh file.sal : outputs to stdout the results of proving file.sal.

# runproof.sh file.sal -p proof_file : outputs to proof_file the results of
# proving file.sal.

# runproof.sh file.sal -p proof_file -e err_file : outputs to proof_file the
# results of proving file.sal and outputs to err_file the standard error from
# SAL.

# --- ARGS ---
# The script takes three options:

# -h --help : displays help (No help exists; please read these comments).

# -p --proof : the optional file to which the output of running the proofs
# should be placed.  Output is a list of proof commands and either 'proved' or
# a counterexample.

# -e --error : the optional file to which standard out is placed.  For example,
# parser problems are placed here.
#
# -c --color : color failed proof checks in red
#

# WARNING: This script overwrites proof and error output files if they already
# exist.

SCRIPT=$0

function usage {
  echo "usage: $SCRIPT sal_file [OPTIONS]"
  echo ""
  echo "  where OPTIONS: [-p proof_out.prf]  proof output file"
  echo "                 [-e error_out.err]  error output file"
  echo "                 [-c]                enable colored output"
  echo "                 [-par]              parameters to SAL model"
  echo "                 [-h]                print usage"
  echo ""
  exit 0
}

function hlp {
  echo "help: to do.  Please read the scripts comments."
  usage
}

# If the number of args is less than 1, then exit on error.
if [ $# \< "1" ]; then
  usage
fi

function valid {
   echo "$1 is not a valid SAL file"
   usage
}

# If the first arg is the help flag, display help info.
if [ $1 == "--help" ] || [ $1 == "-h" ]; then
  hlp
  usage
fi

# If the SAL file doesn't exist, exit on error.
if [ ! -e $1 ]; then
  valid $1
fi

SALFILE="$1"

# default 'color start' and 'color end' commands
CS=""
CG=""
CE=""
# default params
SAL_PARAMS=""

# While there is more than one argument (the SAL file is always the first argument),
# get the remaining arguments.
while [ $# \> "1" ]; do
    case $2 in
        -p | --proof )          shift # Shift past the flag.
                                PRFFILE=$2
                                ;;
        -e | --error )          shift # Shift past the flag.
                                ERRFILE=$2
                                ;;
        -c | --color )          CS="\033[0;31m"  # red
                                CG="\033[0;32m"  # green
                                CE="\033[0m"     # no color
                                ;;
        -par | --parameters )   shift
                                SAL_PARAMS=$2
                                ;;
        * )                     shift # Shift past the flag.
                                ;;
    esac
    shift
done

SALOPT=$(egrep -e '^% runproof: ' $SALFILE | tail -1 | cut -d ' ' -f 3-)

function findsal {
  local file=$1
  cat $file | \
    # look only at comment lines
    egrep -e "^%" | \
    # remove the comment and whitespace from every line
    sed "s/^%[ ]*//" | \
    # join lines that end with a \ into one line
    awk '{if (sub(/\\$/,"")) printf "%s ", $0; else print $0}' | \
    # match lines starting with a commented sal command
    egrep -e "^sal-"
}

function cmd {
    IFS=$'\n'
    declare -a lines=( $(findsal $SALFILE) )
    unset IFS

    printf "\n** Found %d proof commands\n\n" ${#lines[@]}
    local pass=0
    local fail=0
    local start="$(date +%s)"
    for ((i=0; i < ${#lines[@]}; i++))
    do
        # insert SAL options
        # XXX make 'sal-inf-bmc' generic here
        local salcmd=${lines[$i]/sal-inf-bmc/sal-inf-bmc $SALOPT}
        # replace SAL file name with the base name followed by any parameters
        if [ -n "${SAL_PARAMS}" ]; then
            salcmd_params=$(echo $salcmd | \
                sed "s/\(${SALFILE%.sal}\)\(.sal\)\?/\1${SAL_PARAMS}/")
            # For printing the proof command to the console, we quote the
            # SAL context + parameters so they can easily by copy/pasted at
            # the command line and be valid shell commands.
            salcmd_quoted=$(echo $salcmd | \
                sed "s/\(${SALFILE%.sal}\)\(.sal\)\?/'\1${SAL_PARAMS}'/")
        else
            salcmd_params="$salcmd"
            salcmd_quoted="$salcmd"
        fi
        printf "[proving]: %s\n" "$salcmd_quoted"
        local tmp=$(mktemp runproof.XXXXXXXX -ut)
        exec $salcmd_params 2>&1 |\
            tee $tmp |\
            # XXX DRY with the regex, but needs to be quoted two different
            # ways
            awk '/(invalid|failed|Error|induction rule failed)/ \
                     {print "'$CS'" $0 "'$CE'"} \
                 /(proved|no counterexample)/ \
                     {print "'$CG'" $0 "'$CE'"}'
        egrep -E -i -q '(invalid|failed|error|induction rule failed)' $tmp
        if [ $? -eq 0 ]; then
            fail=$(($fail+1))
        else
            pass=$(($pass+1))
        fi
        rm $tmp
    done
    local end="$(date +%s)"

    printf "\n"
    printf "** ${CG}Proofs OK %d${CE} / ${CS}Proofs FAILED %d${CE} **\n" $pass $fail
    printf "\n"

    local t=$(($end-$start))
    printf "total time ellapsed: $t seconds"

    if [ $fail -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

if [ -z "$(type -p sal-inf-bmc)" ]; then
    echo "Error: cannot find SAL executable: sal-inf-bmc"
    exit 1
fi

# Write out to standard out and err to standard error.
if [ -z ${PRFFILE:-} ] && [ -z ${ERRFILE:-} ]; then
 cmd
# Write out to file ${PRFFILE:-} and err to standard error.
elif [ -n ${PRFFILE:-} ] && [ -z ${ERRFILE:-} ]; then
 cmd > ${PRFFILE:-}
# Write out to standard out and err to file ${ERRFILE:-}.
elif [ -z ${PRFFILE:-} ] && [ -n ${ERRFILE:-} ]; then
 cmd &> ${ERRFILE:-}
# Write out to file ${PRFFILE:-} and err to file ${ERRFILE:-}.
elif [ -n ${PRFFILE:-} ] && [ -n ${ERRFILE:-} ]; then
 (cmd > ${PRFFILE:-}) &> ${ERRFILE:-}
fi
