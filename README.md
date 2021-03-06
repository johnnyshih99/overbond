# Yield spread function
2 main functions both accepting path to csv file as their parameter:
* calc_spread_to_benchmark - Calculate the yield spread between a corporate bond and its government bond benchmark.
* calc_spread_to_curve - Calculate the spread to the government bond curve.

## Assumptions
* There's a valid csv input file with fields 'bond,type,term,yield'
  * bond is the name of the bond
  * type is either corporate or government
  * term is given in years
  * yield is given in percentages
* The first row of csv is the title header
* all terms/yields are of different values
* There's at least one gov bond with a term less than all corp bonds and a gov bond with a term greater than all corp bonds for spread_to_curve

## Reasoning behind technical choices
I chose rspec for testing because I've never tried it before and so I thought it's a good chance to get familiar with it

## Design reasons
My design first sorts the entries in increasing term years; that way, any corporate bonds sandwiched in between 2 government bonds will have their term years closest with those 2 government bonds (upper and lower bounds).  
So the entries are looped through; the first government bond will be the lower bound, and all other coroprate bonds are stored in a temporary array. As soon as another government bond is reached, the corporate bonds in temporary array are compared with the lower bound and the current government bond (upper bound). Then, the results are printed to stdout.

This design is more time efficient because we don't have to compare the corporate bond with every government bonds.  
Alternatively, after the entries are sorted, we can use the index position of the corporate bonds and perform a linear search in both directions to find the lower and upper bounds. This solution might provide more clarity and simplicity to the code. However, it will not be as time efficient if there's a big cluster of corporate bonds as it will have to unnecessarily loop through them multiple times.

Using this design, the 2nd challenge becomes trivial as we have both upper and lower bounds to calculate the linear interpolation.

Output of the results are made into function (print_spread) so it can be easily modified to accommodate for other output format (e.g. write into csv file).

The solution can be improved with some error checks (exception handlers) on the input file, or depending on the specification, accept a wider range of input format.  
The tests can be more extensive as well, but it's made easy too add onto them with rspec.

## Tests
run 'rspec ob_spec.rb' in spec folder
* sample_1.csv provides the data for a simple test for spread_to_benchmark
* sample_2.csv provides the data for a simple test for spread_to_curve
* sample_input.csv provides the data for a more complete test for both functionalities
* sample_3.csv provides the data for spread_to_benchmark when the smallest and biggest entries are not government bonds
* expected test results in rspec are manually calculated
