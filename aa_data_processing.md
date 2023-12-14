Processing AA data
================

- <a href="#steps" id="toc-steps">Steps</a>
- <a href="#cleaning-data-file" id="toc-cleaning-data-file">Cleaning data
  file</a>
- <a href="#auto-detect-and-subtract-blanks"
  id="toc-auto-detect-and-subtract-blanks">Auto-detect and subtract
  blanks</a>

## Steps

- Get the functions from the source file
- Input the appropriate `file_name` and run clean_aa_data to keep sample
  data
- Optional: Run subtract_blanks to remove blank values from samples

## Cleaning data file

Read in function using `source_url`:

``` r
devtools::source_url("https://raw.githubusercontent.com/deonlum/aa-data-processing/main/AA_functions.R")
```

Input your file name into the clean_aa_data function. Note the file has
to be a .csv file. Convert the .SLK file in excel (save as comma
delimited).

``` r
file_name = "./sample_data.csv"

clean_data = clean_aa_data(file_name)
```

    ## Data retrieved for: 
    ##  Ammonia Nitrate

``` r
clean_data
```

    ##          sample_id ammonia nitrate
    ## 1               1A   0.273   0.477
    ## 2               2A   0.259   0.580
    ## 3               3A   0.249   0.344
    ## 4               4A   0.262   0.913
    ## 5               5A   0.257   0.443
    ## 6               6A   0.241   0.230
    ## 7               1B   0.273   0.606
    ## 8               2B   0.259   0.666
    ## 9               3B   0.273   0.483
    ## 10              4B   0.265   1.249
    ## 11              5B   0.263   0.578
    ## 12              6B   0.248   0.450
    ## 13      T1 BLANK 1   0.242   0.091
    ## 14      T1 BLANK 2   0.205   0.081
    ## 15      T1 BLANK 3   0.224   0.084
    ## 16             S1A   0.368   9.955
    ## 17             S2A   0.400  10.745
    ## 18             S3A   0.420   8.305
    ## 19             S1B   0.444  10.398
    ## 20             S2B   0.450  11.190
    ## 21             S3B   0.453   8.382
    ## 22 CONTROL BLANK 1   0.336   0.037
    ## 23 CONTROL BLANK 2   0.332   0.049
    ## 24 CONTROL BLANK 3   0.345   0.021
    ## 25           SPARE  -0.124   0.237

What `clean_aa_data` does is pick out the appropriate cells in the .csv
file and puts it all in a nice dataframe for downstream processing. It
does not alter any values at all. clean_aa_data also prints out what
data columns were identified. In this case, this was a KCl run, so it
retrieved data for Ammonia and Nitrate.

Notice that in the sample data file (which is a truncated version of a
real data file), there are multiple sets of samples. First, there are
samples with A and B on them for KCl-A and KCl-B. And there are also
samples from two timepoints: samples 1A/B to 6A/B are from T1, and all
samples with the ‘S’ label are from the control timepoint. I also have
an unwanted SPARE sample at the end.

## Auto-detect and subtract blanks

`subtract_blanks` will identify blanks, take the average, and subtract
this value from all samples. This means if we run the function on the
current dataframe, it will calculate an average using **all** the blanks
(e.g., T1 BLANK 1, CONTROL BLANK 1) and subtract it from **all** the
samples, which is not what we want.

To make sure we get the intended behaviour (e.g. only subtract T1 blanks
from T1 samples), we can subset the relevant rows.

``` r
T1_data = clean_data[1:15,]
T1_data
```

    ##     sample_id ammonia nitrate
    ## 1          1A   0.273   0.477
    ## 2          2A   0.259   0.580
    ## 3          3A   0.249   0.344
    ## 4          4A   0.262   0.913
    ## 5          5A   0.257   0.443
    ## 6          6A   0.241   0.230
    ## 7          1B   0.273   0.606
    ## 8          2B   0.259   0.666
    ## 9          3B   0.273   0.483
    ## 10         4B   0.265   1.249
    ## 11         5B   0.263   0.578
    ## 12         6B   0.248   0.450
    ## 13 T1 BLANK 1   0.242   0.091
    ## 14 T1 BLANK 2   0.205   0.081
    ## 15 T1 BLANK 3   0.224   0.084

And now:

``` r
subtract_blanks(T1_data, blank_pattern = "BLANK")
```

    ##    sample_id    ammonia   nitrate
    ## 1         1A 0.04933333 0.3916667
    ## 2         2A 0.03533333 0.4946667
    ## 3         3A 0.02533333 0.2586667
    ## 4         4A 0.03833333 0.8276667
    ## 5         5A 0.03333333 0.3576667
    ## 6         6A 0.01733333 0.1446667
    ## 7         1B 0.04933333 0.5206667
    ## 8         2B 0.03533333 0.5806667
    ## 9         3B 0.04933333 0.3976667
    ## 10        4B 0.04133333 1.1636667
    ## 11        5B 0.03933333 0.4926667
    ## 12        6B 0.02433333 0.3646667

Note that we have to specify the blank_pattern here (which is
case-sensitive). The default is “B” which doesn’t work here since “B” is
used to denote KCL-B samples. As an alternative, one can also specify
rows:

``` r
my_data = subtract_blanks(T1_data, blank_rows = c(13:15))
```

At this point, it might also be useful to separate A and B values, or
fumigated and unfumigated ones if doing microbial biomass N. A quick tip
is to use grep() to retrieve relevant rows (also useful to subset
differently labelled sites for `subtract_blanks`):

``` r
KCLA = my_data[grep("A", my_data$sample_id),]
KCLB = my_data[grep("B", my_data$sample_id),]

KCLA
```

    ##   sample_id    ammonia   nitrate
    ## 1        1A 0.04933333 0.3916667
    ## 2        2A 0.03533333 0.4946667
    ## 3        3A 0.02533333 0.2586667
    ## 4        4A 0.03833333 0.8276667
    ## 5        5A 0.03333333 0.3576667
    ## 6        6A 0.01733333 0.1446667

``` r
KCLB
```

    ##    sample_id    ammonia   nitrate
    ## 7         1B 0.04933333 0.5206667
    ## 8         2B 0.03533333 0.5806667
    ## 9         3B 0.04933333 0.3976667
    ## 10        4B 0.04133333 1.1636667
    ## 11        5B 0.03933333 0.4926667
    ## 12        6B 0.02433333 0.3646667
