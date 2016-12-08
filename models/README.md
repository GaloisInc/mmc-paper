# SAL models of OMH(1) and Variants

  * om1_cal.sal       - Our original OMH(1) model
  * om1_mvs.sal       - Mid -value selection variant
  * om1_nofault.sal   - No fault model variant
  * om1_omis_asym.sal - Ommissive asymmetric faults variant
  * om1_tt.sal        - Time-tiggered variant

# Verification

To verify the THEOREMS and LEMMAS contained in the models above, use the
`runproof.sh` script, for example:

```
$ ./runproof.sh om1_cal.sal -par '{3,3}'
```

will verify that the OMH(1) system with 3 relays and 3 receivers satisfies all
the properties listed. A summary is printed at the end of the run containing
how many proofs succeeded and how many failed. Note that [SAL](http://sal.csl.sri.com/)
must be installed and in your `$PATH` for verification to work.
