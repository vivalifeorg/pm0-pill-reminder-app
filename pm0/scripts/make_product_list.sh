#! /bin/bash

##takes identifiers that are useful out of the massive file. We should use addin searches to find all other products
tail -n +2 product.readable.txt | cut -f 1,2,4,9,13  > all_products.tsv


