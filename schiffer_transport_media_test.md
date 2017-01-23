Testing Effects of Transport Media Reagents
================

Cytokines measured
------------------

IFN-α2a, IL-17A, IL-18, IL-1α, IL-7, IP-10
MIP-1α, MIP-1β, MIP-3α, IFNg, IL-10, IL-12p70 IL-1β, IL-2, IL-6, IL-8, TNF-α

Checking Standard Recovery and Curves
-------------------------------------

Here are plots of the % recovery (extrapolated concentration/ known concentration x 100) for the standards that were either within or above the detection range, with lines at the "good recovery" limits of 80 and 120% recovery.

The R<sup>2</sup> values for goodness-of-fit for the standard curves were all &gt;0.99

![](schiffer_transport_media_test_files/figure-markdown_github/percent%20recovery-1.png)

Caveats about Standards
-----------------------

-   Standards with values *below the detection range* (&lt;2.5x the standard deviation of the lowest standard) give unreliable concentrations, so I did not include those in the plots.

-   When standards are *below the curve fit* (outside the range of the standard curve), the software does not calculate concentrations so you can't get a percent recovery.

-   Most of the Standards that fell into either of these categories were from the least concentrated standard (diluent only) except for two from Standard 6 and five from standard 7:

<table style="width:53%;">
<colgroup>
<col width="12%" />
<col width="40%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">Sample</th>
<th align="center">Number of Samples Below Fit Curve Range/Detection Range</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">S006</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">S007</td>
<td align="center">5</td>
</tr>
<tr class="odd">
<td align="center">S008</td>
<td align="center">34</td>
</tr>
</tbody>
</table>

<table style="width:53%;">
<colgroup>
<col width="12%" />
<col width="11%" />
<col width="29%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">Sample</th>
<th align="center">Assay</th>
<th align="center">Detection.Range</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">S007</td>
<td align="center">IL-2</td>
<td align="center">Below Detection Range</td>
</tr>
<tr class="even">
<td align="center">S006</td>
<td align="center">MIP-1a</td>
<td align="center">Below Fit Curve Range</td>
</tr>
<tr class="odd">
<td align="center">S006</td>
<td align="center">MIP-1a</td>
<td align="center">Below Detection Range</td>
</tr>
<tr class="even">
<td align="center">S007</td>
<td align="center">MIP-1a</td>
<td align="center">Below Detection Range</td>
</tr>
<tr class="odd">
<td align="center">S007</td>
<td align="center">MIP-1a</td>
<td align="center">Below Fit Curve Range</td>
</tr>
<tr class="even">
<td align="center">S007</td>
<td align="center">MIP-1ß</td>
<td align="center">Below Detection Range</td>
</tr>
<tr class="odd">
<td align="center">S007</td>
<td align="center">MIP-1ß</td>
<td align="center">Below Fit Curve Range</td>
</tr>
</tbody>
</table>

Testing effects of transport media cocktail
-------------------------------------------

We added the following reagents to our usual control CVL pool to mimic the transport medium:

-   Protease Inhibitor at a 1x final concentration (Calbiochem, lot 2746008, catalog \#: 539131-1VL)

-   10% Igepal (Sigma, lot 51K0084, catalog \#: 1-3021)

-   0.25% BSA (Sigma, lot 018K699, cat \# A9647-500G)

We tested both a "neat" and 1:10 dilution of the samples. All samples were run in duplicate.

Results
=======

For some cytokines, some of the sample concentrations fell below the detection range:

<table style="width:82%;">
<colgroup>
<col width="12%" />
<col width="11%" />
<col width="15%" />
<col width="30%" />
<col width="12%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">Assay</th>
<th align="center">Type</th>
<th align="center">Dilution</th>
<th align="center">Detection.Range</th>
<th align="center">Samples</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">IFN-a2a</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">IFN-a2a</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">IFNg</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">IFNg</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">IL-10</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">IL-10</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Fit Curve Range</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">IL-10</td>
<td align="center">Control</td>
<td align="center">neat</td>
<td align="center">Below Detection Range</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">IL-10</td>
<td align="center">Control</td>
<td align="center">neat</td>
<td align="center">Below Fit Curve Range</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">IL-10</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Fit Curve Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">IL-10</td>
<td align="center">Test</td>
<td align="center">neat</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">IL-12p70</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">IL-12p70</td>
<td align="center">Control</td>
<td align="center">neat</td>
<td align="center">Below Fit Curve Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">IL-12p70</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">IL-12p70</td>
<td align="center">Test</td>
<td align="center">neat</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">IL-2</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">IL-2</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">MIP-1a</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">MIP-1a</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="odd">
<td align="center">TNF-a</td>
<td align="center">Control</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">2</td>
</tr>
<tr class="even">
<td align="center">TNF-a</td>
<td align="center">Control</td>
<td align="center">neat</td>
<td align="center">Below Detection Range</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">TNF-a</td>
<td align="center">Test</td>
<td align="center">1:10</td>
<td align="center">Below Detection Range</td>
<td align="center">1</td>
</tr>
</tbody>
</table>

There was a wide range of concentrations across cytokines but the test and control samples were similar. Below are plots showing the calculated concentrations for the *1:10 diluted* and *neat* samples.

Note that the concentrations are plotted on a *log 10* scale.

Some conditions are missing dots: these are ones where the concentration was below the level of detection.

![](schiffer_transport_media_test_files/figure-markdown_github/plot%20diluted-1.png)

![](schiffer_transport_media_test_files/figure-markdown_github/plot%20neat-1.png)

![](schiffer_transport_media_test_files/figure-markdown_github/plotting%20standards%20and%20samples-1.png)
